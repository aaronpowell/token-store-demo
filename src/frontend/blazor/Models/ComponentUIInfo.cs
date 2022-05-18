namespace TokenStore.Models
{
    public class ComponentUIInfo
    {
        public virtual string? ButtonColour { get; set; } = "outline-primary";
        public virtual bool Submitting { get; set; }
        public virtual string? DisplaySpinner { get; set; } = "none";
        public virtual string? AlertResult { get; set; }
        public virtual string? DisplayResult { get; set; } = "none";
        public virtual string? MessageResult { get; set; }
    }
}