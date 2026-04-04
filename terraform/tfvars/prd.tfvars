environment     = "prd"
location        = "uksouth"
subscription_id = "7760848c-794d-4a19-8cb2-52f71a21ac2b"

management_subscriptions = [
  "7760848c-794d-4a19-8cb2-52f71a21ac2b", # sub-platform-management
]

connectivity_subscriptions = [
  "db34f572-8b71-40d6-8f99-f29a27612144", # sub-platform-connectivity
]

identity_subscriptions = [
  "c391a150-f992-41a6-bc81-ebc22bc64376", # sub-platform-identity
]

landing_zone_subscriptions = [
  "655da25d-da46-40c0-8e81-5debe2dcd024", # sub-mx-consulting-prd
  "845766d6-b73f-49aa-a9f6-eaf27e20b7a8", # sub-xi-demomanager-prd
  "f857cea2-c7c0-4aef-b6b6-0c1ed18aafde", # Personal-Pay-As-You-Go
  "d3b204ab-7c2b-47f7-8d5a-de19e85591e7", # sub-fm-geolocation-prd
  "903b6685-c12a-4703-ac54-7ec1ff15ca43", # sub-platform-shared
  "32444f38-32f4-409f-889c-8e8aa2b5b4d1", # sub-xi-portal-prd
  "02174fb6-b8f3-4bd7-8be8-99f271c3dc20", # sub-xi-dedi-server-prd
  "1b5b28ed-1365-4a48-b285-80f80a6aaa1b", # sub-enterprise-devtest-legacy
  "d68448b0-9947-46d7-8771-baa331a3063a", # sub-visualstudio-enterprise-legacy
  "6cad03c1-9e98-4160-8ebe-64dd30f1bbc7", # sub-visualstudio-enterprise
  "e1e5de62-3573-4b44-a52b-0f1431675929", # sub-talkwithtiles
  "957a7d34-8562-4098-bb4c-072e08386d07", # sub-finances-prd
  "ef3cc6c2-159e-4890-9193-13673dded835", # sub-molyneux-me-dev
  "3cc59319-eb1e-4b52-b19e-09a49f9db2e7", # sub-molyneux-me-prd
]

sandbox_subscriptions = [
  "4ebd4bf2-7dd9-40b0-b2a4-e687ded49112", # Pay-As-You-Go Dev/Test
]

decommissioned_subscriptions = []

breakglass_principal_id = "f18d451b-2b22-4708-81f7-0888cf71f525" # breakglass@molyneuxio.onmicrosoft.com

tags = {
  Environment = "prd"
  Workload    = "platform-landing-zones"
  DeployedBy  = "GitHub-Terraform"
  Git         = "https://github.com/frasermolyneux/platform-landing-zones"
}
