var builder = WebApplication.CreateSlimBuilder(args);

builder.Services.AddWindowsService(options =>
{
    options.ServiceName = "DummyApi";
});

var app = builder.Build();

app.MapGet("/", () => Results.Text("Hello, World!"));

app.Run();
