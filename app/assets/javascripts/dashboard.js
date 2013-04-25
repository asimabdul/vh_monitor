function getStatus() {
  $.get("/status", function(data){
    for (var status in data.job_statuses) {
      $("." + data.job_statuses[status]['name']).addClass(data.job_statuses[status]['color']);
      var branch_details = "(" + data.job_statuses[status]['branch'] + ")";
      $("." + data.job_statuses[status]['name']).find(".details").text(data.job_statuses[status]['updated_at'] + " " + branch_details);
    }
  })
}

$(document).ready(function(){
  setInterval(getStatus, 4000);
})