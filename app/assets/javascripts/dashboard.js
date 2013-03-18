function getStatus() {
  $.get("/status", function(data){
    $(".status-box").css("background-color", data.ci);
  })
}

$(document).ready(function(){
  setInterval(getStatus, 4000);
})