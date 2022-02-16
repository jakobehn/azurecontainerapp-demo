using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using orderweb.Models;

namespace orderweb.Controllers;

public class OrderController : Controller
{
    private readonly ILogger<OrderController> _logger;

    public OrderController(ILogger<OrderController> logger)
    {
        _logger = logger;
    }

    public async Task<IActionResult> Index()
    {
        var client = new Dapr.Client.DaprClientBuilder().Build();
        var orders = await client.InvokeMethodAsync<List<Order>>(HttpMethod.Get, "orderapi", "order");

        var model = new OrdersViewModel()
        {
            Orders = orders
        };
        return View(model);
    }

    public async Task<IActionResult> Create()
    {
        return View();
    }    

    public async Task<IActionResult> Send(Order order)
    {
        var client = new Dapr.Client.DaprClientBuilder().Build();
        await client.InvokeMethodAsync<Order>("orderapi", "order", order);
                
        return RedirectToAction("Index");
    }



    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
