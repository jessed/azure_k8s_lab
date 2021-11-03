#! /bin/tclsh

# This iCall script checks for termination events and, if found
# disables new connections by disabling the health-check virtual-server

set headers           "Metadata:true"
set instanceMetadata  "http://169.254.169.254/metadata/instance?api-version=2021-02-01"
set eventMetadata     "http://169.254.169.254/metadata/scheduledevents?api-version=2020-07-01"

set eventType   {.Events[0].EventType}
set eventHosts  {.Events[0].Resources[]}
set nameFilter  {.compute.name}


set eventType  [exec curl -0s -H $headers $eventMetadata | jq -r $eventType]

if { $eventType == "Terminate" } {
  set myName     [exec curl -0s -H $headers $instanceMetadata | jq -r $nameFilter]
  set eventHosts [exec curl -0s -H $headers $eventMetadata | jq -r $eventHosts]

  foreach {target} $eventHosts {
    puts "target: $target, myName: $myName"
    if { $target == $myName } {
      puts "Disabling virtual (target: $target, myName: $myName)"
      #exec tmsh modify ltm virtual vs00-health_check disabled
    }
  }
}
