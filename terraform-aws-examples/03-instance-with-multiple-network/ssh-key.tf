# Define ssh to config in instance

# Create default ssh publique key
resource "aws_key_pair" "user_key" {
  key_name   = "charles.pem"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/pGKe4m0/7WFJFnsHBu+uv4QtjlMapBf2JL72tSXMuDQ/i85WMjs9VZ3QXyupqneIB9oFqod3J8HhNA62xPxNZly5GwtKIc+mkBQ2zFzyWKKXX77dqPEEgHq8xL2nhKkPc7OlxLoBL/Ao54GauQDX4UpyQXiPcGITb1KwTRExpze6Hxv2EheF98EH5eu8ped+hNxgfCstPR/d/O2AeCWe1ajxyN8znlajcfXYi/u/8Wm6qDagKck9QgxivK4hs9VytwrT1Vt93jiNePKkI04bT4udQJRtqqcjLZZJ8SaVvq7jwvZRv/2dD7muF60ws/vCrowp4WE9tUOa/y61eoSJ charles.lee@C02YM2BWJG5H.local"
}

