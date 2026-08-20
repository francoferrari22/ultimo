using Microsoft.Data.Sqlite;
using System.Globalization;

var builder = WebApplication.CreateBuilder(args);
var apiKey = builder.Configuration["ApiKey"] ?? "";
var configuredDb = builder.Configuration["DatabasePath"] ?? "%APPDATA%\\FerrarisPOS\\FerrarisPOS.db";
var dbPath = Environment.ExpandEnvironmentVariables(configuredDb);

builder.WebHost.UseUrls("http://0.0.0.0:5077");
var app = builder.Build();

app.Use(async (ctx, next) =>
{
    if (ctx.Request.Path == "/health") { await next(); return; }
    if (string.IsNullOrWhiteSpace(apiKey) || !string.Equals(ctx.Request.Headers["X-API-Key"].FirstOrDefault(), apiKey, StringComparison.Ordinal))
    {
        ctx.Response.StatusCode = 401;
        await ctx.Response.WriteAsJsonAsync(new { error = "API key inválida" });
        return;
    }
    await next();
});

app.MapGet("/health", () => Results.Ok(new { ok = true, service = "FerrariPOS Mobile Bridge", version = "1.0" }));

app.MapGet("/api/dashboard", async () =>
{
    await using var db = Open(dbPath);
    var today = DateTime.Now.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
    var sales = await Scalar(db, "SELECT COALESCE(SUM(total),0) FROM sales WHERE status='COMPLETED' AND date(created_at)=date($d)", ("$d", today));
    var tickets = await Scalar(db, "SELECT COUNT(*) FROM sales WHERE status='COMPLETED' AND date(created_at)=date($d)", ("$d", today));
    var credit = await Scalar(db, "SELECT COALESCE(SUM(CASE WHEN entry_type='CHARGE' THEN amount WHEN entry_type='PAYMENT' THEN -amount ELSE 0 END),0) FROM customer_accounts");
    var low = await Scalar(db, "SELECT COUNT(*) FROM products WHERE active=1 AND stock <= min_stock");
    return Results.Ok(new { salesToday = sales, ticketsToday = tickets, totalCredit = credit, lowStock = low });
});

app.MapGet("/api/sales", async (int? limit, string? from, string? to) =>
{
    await using var db = Open(dbPath);
    var take = Math.Clamp(limit ?? 50, 1, 200);
    var sql = @"SELECT s.id, s.ticket_no ticketNo, COALESCE(c.name,'Público General') customer, s.total,
                       s.payment_method paymentMethod, s.status, s.created_at createdAt
                FROM sales s LEFT JOIN customers c ON c.id=s.customer_id
                WHERE s.status='COMPLETED'
                  AND ($from='' OR date(s.created_at)>=date($from))
                  AND ($to='' OR date(s.created_at)<=date($to))
                ORDER BY s.id DESC LIMIT $take";
    return Results.Ok(await Query(db, sql, new() { ["$from"] = from ?? "", ["$to"] = to ?? "", ["$take"] = take }));
});

app.MapGet("/api/sales/{id:long}", async (long id) =>
{
    await using var db = Open(dbPath);
    var sale = await Query(db, "SELECT s.*, COALESCE(c.name,'Público General') customer_name FROM sales s LEFT JOIN customers c ON c.id=s.customer_id WHERE s.id=$id", new() { ["$id"] = id });
    var items = await Query(db, "SELECT description, quantity, unit_price unitPrice, total FROM sale_items WHERE sale_id=$id ORDER BY id", new() { ["$id"] = id });
    return Results.Ok(new { sale = sale.FirstOrDefault(), items });
});

app.MapGet("/api/credits", async () =>
{
    await using var db = Open(dbPath);
    var sql = @"SELECT c.id, c.name, c.phone, c.credit_limit creditLimit,
                       COALESCE(SUM(CASE WHEN a.entry_type='CHARGE' THEN a.amount WHEN a.entry_type='PAYMENT' THEN -a.amount ELSE 0 END),0) balance
                FROM customers c LEFT JOIN customer_accounts a ON a.customer_id=c.id
                GROUP BY c.id,c.name,c.phone,c.credit_limit
                HAVING balance <> 0 ORDER BY balance DESC";
    return Results.Ok(await Query(db, sql));
});

app.MapGet("/api/customers", async (string? q) =>
{
    await using var db = Open(dbPath);
    var sql = @"SELECT id,name,phone,email,credit_limit creditLimit FROM customers
                WHERE active=1 AND ($q='' OR name LIKE '%'||$q||'%' OR phone LIKE '%'||$q||'%')
                ORDER BY name LIMIT 200";
    return Results.Ok(await Query(db, sql, new() { ["$q"] = q ?? "" }));
});

app.MapGet("/api/customers/{id:long}", async (long id) =>
{
    await using var db = Open(dbPath);
    var customer = await Query(db, "SELECT * FROM customers WHERE id=$id", new() { ["$id"] = id });
    var movements = await Query(db, "SELECT entry_type entryType, amount, concept, payment_method paymentMethod, created_at createdAt FROM customer_accounts WHERE customer_id=$id ORDER BY id DESC LIMIT 200", new() { ["$id"] = id });
    return Results.Ok(new { customer = customer.FirstOrDefault(), movements });
});

app.MapGet("/api/products", async (string? q) =>
{
    await using var db = Open(dbPath);
    var sql = @"SELECT id,barcode,description,sale_price salePrice,cost_price costPrice,stock,min_stock minStock,category,unit
                FROM products WHERE active=1 AND ($q='' OR description LIKE '%'||$q||'%' OR barcode LIKE '%'||$q||'%') ORDER BY description LIMIT 300";
    return Results.Ok(await Query(db, sql, new() { ["$q"] = q ?? "" }));
});

app.MapGet("/api/cash", async () =>
{
    await using var db = Open(dbPath);
    var sessions = await Query(db, "SELECT id,opened_at openedAt,closed_at closedAt,opening_amount openingAmount,closing_amount closingAmount,expected_amount expectedAmount,difference,status FROM cash_sessions ORDER BY id DESC LIMIT 50");
    var movements = await Query(db, "SELECT id,movement_type movementType,concept,amount,payment_method paymentMethod,created_at createdAt FROM cash_movements ORDER BY id DESC LIMIT 100");
    return Results.Ok(new { sessions, movements });
});

app.Run();

static SqliteConnection Open(string path)
{
    if (!File.Exists(path)) throw new FileNotFoundException("No se encontró la base de FerrariPOS", path);
    var cn = new SqliteConnection($"Data Source={path};Mode=ReadOnly;Foreign Keys=True;");
    cn.Open();
    return cn;
}

static async Task<object?> Scalar(SqliteConnection db, string sql, params (string,string)[] args)
{
    await using var cmd = db.CreateCommand(); cmd.CommandText = sql;
    foreach (var (k,v) in args) cmd.Parameters.AddWithValue(k,v);
    return await cmd.ExecuteScalarAsync();
}

static async Task<List<Dictionary<string,object?>>> Query(SqliteConnection db, string sql, Dictionary<string,object?>? args = null)
{
    await using var cmd = db.CreateCommand(); cmd.CommandText = sql;
    if (args != null) foreach (var kv in args) cmd.Parameters.AddWithValue(kv.Key, kv.Value ?? DBNull.Value);
    await using var reader = await cmd.ExecuteReaderAsync();
    var list = new List<Dictionary<string,object?>>();
    while (await reader.ReadAsync())
    {
        var row = new Dictionary<string,object?>(StringComparer.OrdinalIgnoreCase);
        for (var i=0;i<reader.FieldCount;i++) row[reader.GetName(i)] = reader.IsDBNull(i) ? null : reader.GetValue(i);
        list.Add(row);
    }
    return list;
}
