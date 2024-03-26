# Define ssh to config in instance
  
# Create default ssh publique key
resource "aws_key_pair" "user_key" {
  key_name   = "charles1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNjUjnmfXIsDQHPGS6y45a/cxVVOA6SFnA2nZZW5WFEwMj6RSBK+/oB+Rrcu+UDKQs9bqz1Nte7BM+N2Cvf295z7FKKtn8MBGG4NXXqq3wi9FwCinJf6oNrEqtoJnJNJwt9zyGvqxqY/yW2eG9JAmFO1YZsNB7CD3+pX7DB26ZvNuufWthUzxxnWbyKlW7nnAKtpy+Qw9YGx3xpkOPQ4AS0UJqFjM1mXv9zeVzWVOGt3nEbihjHwRUuiWM2EkyEsPEm0nscPLxoGKbrKolnrDwy/p9ZdFCTXeSrYwAlWuE0BAzBDBeR7ErApQPJ3vvdYwf49BFwEKg/dC1lP0fn8ch charles.lee@aktana.com"
}
