function getStatus() {
  $.get("/status", function(data){
    for (var status in data.job_statuses) {
      status_div = $("." + data.job_statuses[status]['name']);
      status_div.removeClass('blue orange red green gray');
      status_div.addClass(data.job_statuses[status]['color']);

      status_div.find(".timestamp").text(data.job_statuses[status]['updated_at']);

      var branch_details = "(" + data.job_statuses[status]['branch'] + " by " + data.job_statuses[status]['author'] + ")";
      status_div.find(".details").text(branch_details);
    }
  })
}

$(document).ready(function(){
  setInterval(getStatus, 4000);
})