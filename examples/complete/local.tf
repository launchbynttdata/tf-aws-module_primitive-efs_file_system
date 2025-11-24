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

locals {
  # Generate the EFS name: use provided name or fall back to resource_names module output
  efs_name = var.name != null ? var.name : module.resource_names["efs"].standard

  # Generate the creation token: use provided value or fall back to the EFS name
  creation_token = var.creation_token != null ? var.creation_token : local.efs_name
}
