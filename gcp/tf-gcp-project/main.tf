resource "google_project" "this" {
  project_id = var.project_id
  name      = var.name
  folder_id = var.folder_id
  auto_create_network = false
}
