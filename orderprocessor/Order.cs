namespace orderprocessor;

public class Order
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public string? Item { get; set; }
    public int Quantity { get; set; }
    
}