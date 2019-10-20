param()
try{
    $Error.Clear()
    Get-Process | Select-Object Name
}catch{

}
