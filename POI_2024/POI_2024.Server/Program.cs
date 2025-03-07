using Microsoft.EntityFrameworkCore;
using POI_2024.Server.DBContext;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using POI_2024.Server.Hubs;


var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddSignalR();
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowSpecificOrigin", builder =>
    {
        builder.WithOrigins("https://localhost:5173")
               .AllowAnyHeader()
               .AllowAnyMethod()
               .AllowCredentials();
    });
});


builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));


//CORS, sirve para que el backend autorice que fronts externos puedan acceder a �l
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowReactApp",
        builder =>
        {
            builder.WithOrigins("https://localhost:5173") // la path del origen externo que va a acceder al back
                   .AllowAnyMethod()
                   .AllowAnyHeader();
        });
});

var app = builder.Build();

app.UseDefaultFiles();
app.UseStaticFiles();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    app.UseDeveloperExceptionPage();
}

IApplicationBuilder applicationBuilder = app.UseHttpsRedirection();

app.UseCors("AllowReactApp"); // aplica los cambios del cors
app.UseAuthorization();
app.UseCors("AllowSpecificOrigin");

app.MapControllers();
app.MapHub<ChatHub>("/chatHub");
app.MapHub<VideoChatHub>("/VideochatHub");
app.MapHub<GlobalHub>("/GlobalHub");
app.MapFallbackToFile("/index.html");

app.Run();
