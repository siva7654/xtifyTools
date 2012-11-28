$(document).bind("mobileinit", function(){
  $.mobile.defaultPageTransition = 'slide';
});

function loadLatest() {
    var URL = "http://gdata.youtube.com/feeds/api/users/fastlanedaily/uploads?v=2&alt=jsonc&max-results=25";
    $.ajax({
        type: "GET",
        url: URL,
        cache: false,
        dataType:'jsonp',
        success: function(data){
            $.each(data.data.items, function(index) { 
                var dateArray = this.uploaded.split("-");
                var date = parseInt(dateArray[1])+"/"+(dateArray[2]).toString().substr(0,2)+"/"+dateArray[0];
                var tn = this.thumbnail.sqDefault;
                var count = this.viewCount; 
                var title = this.title;
                                    
                //var link = getAttributeByIndex(this.player, 0); 
                var videoId = this.id;
                $('#fldFeedItems').append("<li><a id='" + videoId + "' href='#' onClick='javascript:loadItem(this)'><img src='" + tn + "' width='120' alt='" + title + "' /><h3>"+title+"</h3><p>" + count + " views - added " +  date  + " </p></a></li>");  
            });
            $("#fldFeedItems").listview('refresh');
        }
    });
}

function loadPopular() {
    var URL = "http://gdata.youtube.com/feeds/api/users/fastlanedaily/uploads?orderby=viewCount&v=2&alt=jsonc";
    $.ajax({
        type: "GET",
        url: URL,
        cache: false,
        dataType:'jsonp',
        success: function(data){
            $.each(data.data.items, function(index) { 
                var dateArray = this.uploaded.split("-");
                var date = parseInt(dateArray[1])+"/"+(dateArray[2]).toString().substr(0,2)+"/"+dateArray[0];
                var tn = this.thumbnail.sqDefault;
                var count = this.viewCount; 
                var title = this.title;
                                    
                //var link = getAttributeByIndex(this.player, 0); 
                var videoId = this.id;
                $('#fldFeedItemsPop').append("<li><a id='" + videoId + "' href='#' onClick='javascript:loadItem(this)'><img src='" + tn + "' width='120' alt='" + title + "' /><h3>"+title+"</h3><p>" + count + " views - added " +  date  + " </p></a></li>");  
            });
            $("#fldFeedItemsPop").listview('refresh');
        }
    });
}


function loadFavorite() {
    var URL = "https://gdata.youtube.com/feeds/api/users/fastlanedaily/favorites?v=2&alt=jsonc";
    $.ajax({
        type: "GET",
        url: URL,
        cache: false,
        dataType:'jsonp',
        success: function(data){
            $.each(data.data.items, function(index) { 
                var dateArray = this.uploaded.split("-");
                var date = parseInt(dateArray[1])+"/"+(dateArray[2]).toString().substr(0,2)+"/"+dateArray[0];
                var tn = this.thumbnail.sqDefault;
                var count = this.viewCount; 
                var title = this.title;
                                    
                //var link = getAttributeByIndex(this.player, 0); 
                var videoId = this.id;
                $('#fldFeedItemsFav').append("<li><a id='" + videoId + "' href='#' onClick='javascript:loadItem(this)'><img src='" + tn + "' width='120' alt='" + title + "' /><h3>"+title+"</h3><p>" + count + " views - added " +  date  + " </p></a></li>");  
            });
            $("#fldFeedItemsFav").listview('refresh');
        }
    });
}

function loadItem(itemObj) {
    var videoId = itemObj.id;
    //call youtube API and get video elements for video ID passed by the feed list
    var URL = "https://gdata.youtube.com/feeds/api/videos/" + videoId + "?v=2&alt=jsonc";

    $.ajax({
        type: "GET",
        url: URL,
        cache: false,
        dataType:'jsonp',
        success: function(data){
            var obj = jQuery.parseJSON(data);
            var dateArray = data.data.updated.split("-");
            var date = parseInt(dateArray[1])+"/"+(dateArray[2]).toString().substr(0,2)+"/"+dateArray[0];
            //var tn = this.thumbnail.sqDefault;
            //var count = this.viewCount; 
                
            var title = data.data.title;
            var description = data.data.description;
            var videoUrl = getAttributeByIndex(data.data.content, 0); 
            var embedCode = '<iframe src="http://www.youtube.com/embed/' + videoId + '" class="youtube-player" type="text/html" width="290" height="160"  frameborder="0"></iframe>';
            $('#fldItem #fldItemTitle').html(title);
            $('#fldItem #fldItemDesc').html(description);
            $('#fldItem #fldItemContent').html(embedCode);
        }
    });
    $("#fldItem").click();
    
}

// Used to get an element from an object
function getAttributeByIndex(obj, index){
  var i = 0;
  for (var attr in obj){
    if (index === i){
      return obj[attr];
    }
    i++;
  }
  return null;
}