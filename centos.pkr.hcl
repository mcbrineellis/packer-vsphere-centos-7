locals {
  build_by      = "Built by: HashiCorp Packer ${packer.version}"
  build_date    = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  build_version = formatdate("MMDD.hhmm", timestamp())
}

source "vsphere-iso" "centos" {
    # Connection Configuration
    vcenter_server        = "${var.vcenter_server}"
    username              = "${var.vsphere_username}"
    password              = "${var.vsphere_password}"
    insecure_connection   = "true"
    datacenter            = "${var.vsphere_datacenter}"

    # Location Configuration
    vm_name               = "${var.vm_guest_os_family}-${var.vm_guest_os_name}-${var.vm_guest_os_version}"
    folder                = "${var.vsphere_folder}"
    cluster               = "${var.vsphere_cluster}"
    datastore             = "${var.vsphere_datastore}"

    # Hardware Configuration
    CPUs                  = "${var.vm_cpu_cores}"
    RAM                   = "${var.vm_mem_size}"
    firmware              = "${var.vm_firmware}"
    
    # Enable nested hardware virtualization for VM. Defaults to false.
    NestedHV              = "false"
 
    # Boot Configuration
    boot_command          = [
      "<wait>e<down><down><end><bs><bs><bs><bs><bs>",
      "text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<leftCtrlOn>x<leftCtrlOff>"
    ]
    boot_wait             = "1s"

    # HTTP Directory Configuration
    http_directory        = "http"

    # Shutdown Configuration
    shutdown_command      = "sudo shutdown -P now"

    # ISO Configuration
    iso_checksum          = "file:http://mirror.csclub.uwaterloo.ca/centos/7.9.2009/isos/x86_64/sha256sum.txt"
    iso_url               = "http://mirror.csclub.uwaterloo.ca/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-Minimal-2009.iso"

    # VM Configuration
    guest_os_type         = "centos7_64Guest"
    notes                 = "Version: v${local.build_version}\nBuilt on: ${local.build_date}\n${local.build_by}"
    disk_controller_type  = ["pvscsi"]
    storage {
      disk_size           = "${var.vm_disk_size}"
      disk_thin_provisioned = "true"
    }
    network_adapters {
      network             = "${var.vsphere_network}"
      network_card        = "vmxnet3"
    }

    # Communicator Configuration
    communicator          = "ssh"
    ssh_username          = "ansible"
    ssh_private_key_file  = "~/.ssh/id_ed25519"
    ssh_timeout           = "20m"

    # Create as template
    # convert_to_template   = "true"

    # Deploy to content library
    content_library_destination {
      library = "${var.content_library}"
      ovf = true
      destroy = true
      description = "Version: v${local.build_version}\nBuilt on: ${local.build_date}\n${local.build_by}"
    }

    # Wait 2m for IP to settle
    ip_settle_timeout = "2m"
}

build {
  sources = ["source.vsphere-iso.centos"]

  provisioner "shell" {
    inline = [
      "echo 'Updating all system packages'",
      "sudo yum update -y",
      "echo 'Cleaning up network devices'",
      "sudo rm -f /etc/udev/rules.d/70-persistent-net.rules",
      "sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-*",
      "sudo find /var/lib/dhclient -type f -exec rm -f '{}' +"
    ]
  }
}