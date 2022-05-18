namespace TokenStore.Models
{
    public class UserInfo
    {
        public virtual string? FirstName { get; set; }
        public virtual string? LastName { get; set; }
        public virtual string? Email { get; set; }
        public virtual string? Phone { get; set; }
    }

    public class ComponentUIInfo
    {
        public virtual string? ButtonColour { get; set; }
        public virtual bool Submitting { get; set; }
        public virtual string? DisplaySpinner { get; set; }
        public virtual string? AlertResult { get; set; }
        public virtual string? DisplayResult { get; set; }
        public virtual string? MessageResult { get; set; }
    }
}