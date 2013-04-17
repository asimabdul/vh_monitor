function getStatus() {
  $.get("/status", function(data){
    for (var status in data.job_statuses) {
      $("." + data.job_statuses[status]['name']).css("background-color", data.job_statuses[status]['color']);
    }
  })
}

$(document).ready(function(){
  setInterval(getStatus, 4000);
})