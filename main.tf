terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  # token     = "AQAAAABeagchAATuwY8-jsMf5EZol-5ZsgRddA8"
  token     = var.yandex_token_export
  cloud_id  = "b1goon3q207eivvefts0"
  folder_id = "b1gkgthf18fqkuii66ht"
  zone      = "ru-central1-b"
}

# token: AQAAAABeagchAATuwY8-jsMf5EZol-5ZsgRddA8
# cloud-id: b1goon3q207eivvefts0
# folder-id: b1gkgthf18fqkuii66ht
# compute-default-zone: ru-central1-b


# Настройка машины
resource "yandex_compute_instance" "vm-1" {
  name = "netology-1"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd82b8qen6p7dri7kpi7"
      #image_id = "fd87va5cc00gaq2f5qfb"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user_data = "${file("~/terraform_prj/cloud_config.yaml")}"
  }
}

resource "yandex_compute_instance" "vm-2" {
  name = "netology-2"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd82b8qen6p7dri7kpi7"
      # image_id = "fd87va5cc00gaq2f5qfb"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user_data = "${file("~/terraform_prj/cloud_config.yaml")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.13.0/24"]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}


output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

output "external_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}