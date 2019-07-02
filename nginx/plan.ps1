$pkg_name="nginx"
$pkg_origin="core"
$pkg_version="1.17.1"
$pkg_description="NGINX web server."
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=('BSD-2-Clause')
$pkg_source="https://nginx.org/download/nginx-$pkg_version.zip"
$pkg_upstream_url="https://nginx.org/"
$pkg_shasum="ef537959fbe10a1f138246e0a7c4e82ce97195ef058e851335d350f3d9562673"
$pkg_bin_dirs=@('bin')
$pkg_exports=@{port="http.listen.port"}
$pkg_exposes=@('port')

function Invoke-Install {
    $source = "$HAB_CACHE_SRC_PATH/$pkg_name-$pkg_version/$pkg_name-$pkg_version"
    Copy-Item "$source/$pkg_name.exe" "$pkg_prefix\bin"
    Get-ChildItem $source | Where-Object {
        $_.PSIsContainer  -and $_.GetFiles().Count
    } | ForEach-Object {
        Copy-Item $_.FullName $pkg_prefix
    }
    mkdir "$pkg_prefix\hooks"

    @"
Set-Location {{pkg.svc_path}}
mkdir temp -ErrorAction SilentlyContinue
if(Test-Path conf) { Remove-Item conf -Recurse -Force }
Copy-Item config conf -Recurse
(Get-Content conf/nginx.conf).replace('\', '/') | Set-Content conf/nginx.conf

nginx
"@ | Out-File "$pkg_prefix\hooks\run"
}
