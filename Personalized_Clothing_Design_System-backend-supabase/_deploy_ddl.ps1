$token = "sbp_0499d4fb6384e9e7f1e6d2b5c2083ac5b867dae7"
$projectRef = "sgovsejqrtznvnyuyesr"

function Invoke-SqlApi($sql) {
    $bodyObj = @{ query = $sql }
    $jsonStr = $bodyObj | ConvertTo-Json -Depth 10 -Compress
    $body = [System.Text.Encoding]::UTF8.GetBytes($jsonStr)
    $req = [System.Net.HttpWebRequest]::Create("https://api.supabase.com/v1/projects/$projectRef/database/query")
    $req.Method = "POST"; $req.ContentType = "application/json"
    $req.Headers.Add("Authorization", "Bearer $token")
    $req.ContentLength = $body.Length
    $s = $req.GetRequestStream(); $s.Write($body, 0, $body.Length); $s.Close()
    try {
        $resp = $req.GetResponse()
        $r = New-Object System.IO.StreamReader($resp.GetResponseStream())
        return "OK: $($r.ReadToEnd())"
    } catch [System.Net.WebException] {
        $er = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        return "FAIL: $($er.ReadToEnd())"
    }
}

$migrations = @(
    "supabase\migrations\202603110001_init.sql",
    "supabase\migrations\202604050001_business_tables.sql",
    "supabase\migrations\202604050002_regen_rpc.sql",
    "supabase\migrations\202604050003_storage_bucket.sql"
)

foreach ($f in $migrations) {
    $sql = Get-Content $f -Raw -Encoding UTF8
    $result = Invoke-SqlApi $sql
    echo "$f => $result"
}
