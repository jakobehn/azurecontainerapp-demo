namespace orderweb.Models;

public class OrdersViewModel
{
    public OrdersViewModel()
    {
        this.Orders = new List<Order>();
    }

    public List<Order> Orders {get; set;}
}