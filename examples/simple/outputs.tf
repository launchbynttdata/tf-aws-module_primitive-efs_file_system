// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

output "file_system_id" {
  description = "The ID of the EFS file system"
  value       = module.efs.file_system_id
}

output "file_system_arn" {
  description = "Amazon Resource Name of the file system"
  value       = module.efs.file_system_arn
}

output "file_system_dns_name" {
  description = "The DNS name for the filesystem"
  value       = module.efs.file_system_dns_name
}

output "file_system_creation_token" {
  description = "The creation token of the EFS file system"
  value       = module.efs.file_system_creation_token
}

output "file_system_name" {
  description = "The value of the file system's Name tag"
  value       = module.efs.file_system_name
}
