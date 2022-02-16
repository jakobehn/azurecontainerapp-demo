namespace orderweb;

public class Order
{
    public Order()
    {
        this.Id = Guid.NewGuid();
        this.CreatedAt = DateTime.Now;
        this.Item = string.Empty;
    }
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public string Item { get; set; }
    public int Quantity { get; set; }
    
}