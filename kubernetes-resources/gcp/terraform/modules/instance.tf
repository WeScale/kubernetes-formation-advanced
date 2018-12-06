resource "google_compute_instance" "training-instance" {
  count                     = "${var.MOD_COUNT}"
  name                      = "training-instance-${count.index}"
  machine_type              = "g1-small"
  zone                      = "${var.MOD_REGION}-b"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-1710-artful-v20171122"
      type  = "pd-standard"
      size  = "10"                                                                  # ie 10GB
    }

    auto_delete = true
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.training_subnet.name}"

    access_config {
      # Ephemeral
    }
  }

  metadata {
    ssh-keys = "training:${file("${path.cwd}/../../kubernetes-formation.pub")}"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform", "compute-rw", "storage-rw"]
    email  = "admin-cluster@sandbox-wescale.iam.gserviceaccount.com"
  }

  metadata_startup_script = "curl -s https://raw.githubusercontent.com/WeScale/kubernetes-formation-advanced/master/kubernetes-resources/gcp/terraform/modules/bootstrap-vm.sh | bash -s ${count.index}"
}
