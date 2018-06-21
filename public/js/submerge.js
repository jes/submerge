var FEED;
$(document).ready(function() {
    var subs = [];
    var running = 0;

    /* https://stackoverflow.com/questions/1219860/html-encoding-lost-when-attribute-read-from-input-field#1219983 */
    function htmlEncode(value){
      // Create a in-memory div, set its inner text (which jQuery automatically encodes)
      // Then grab the encoded contents back out. The div never exists on the page.
      return $('<div/>').text(value).html();
    }

    function htmlDecode(value){
      return $('<div/>').html(value).text();
    }

    function processing(n) {
        running += n;
        if (running > 0) {
            $('#processing').show();
        } else {
            $('#processing').hide();
        }
    }

    function fetch_subs() {
        $.ajax("/subs", {
            success: function(r) {
                subs = r;
                redraw_subs();
            },
            error: function(xhr) {
                alert("Error");
                processing(-1);
            },
        }); // TODO: handle errors
    }

    function redraw_subs() {
        var url = window.location.origin + "/feeds/videos.xml?channel_id=";
        var ids = [];
        var names = [];
        for (var i = 0; i < subs.length; i++) {
            ids.push(subs[i].channel_id);
            names.push("<a href=\"https://hooktube.com/channel/" + escape(subs[i].channel_id) + "\">" + htmlEncode(subs[i].name) + "</a>");
        }
        url += ids.join(",");
        $('#feed-url').attr('href', url);
        $('#feed-url-span').text(url);
        $('#channels-span').html(names.join(', '));

        if (ids.length > 0) {
            $('#current-subs').show();
        } else {
            $('#current-subs').hide();
        }

        var thumbshtml = '';

        /* https://stackoverflow.com/a/7067582 */
        $.get(url, function(data) {
            var $xml = $(data);
            $xml.find("entry").each(function() {
                var $this = $(this);
                var item = {
                        title: $this.find("title").text(),
                        link: $this.find("link")[0].attributes.href.value,
                        description: $this.find("description").text(),
                        published: $this.find("published").text(),
                        thumbnail: $this.find("media:thumbnail").text(),
                        author: $this.find("name").text(),
                        authoruri: $this.find("uri").text(),
                };

                // XXX: $this.find() doesn't work for element names with a colon in, so
                // we have to search for the media:thumbnail manually
                for (var i = 0; i < $this.children().length; i++) {
                    if ($this.children()[i].nodeName == 'media:group') {
                        for (var j = 0; j < $this.children()[i].children.length; j++) {
                            if ($this.children()[i].children[j].nodeName == 'media:thumbnail') {
                                item.thumbnail = $this.children()[i].children[j].attributes.url.value;
                            }
                        }
                    }
                }

                thumbshtml += "<div style=\"margin:2px; display: inline-block; width: 360px; height: 77px; overflow:hidden; text-overflow: ellipsis; font-size: 0.8em\"><a href=\"" + htmlEncode(item.link) + "\"><img style=\"width: 100px; float: left; margin: 2px\" src=\"" + htmlEncode(item.thumbnail) + "\">" + htmlEncode(item.title) + "</a><br><a class=\"text-muted\" href=\"" + htmlEncode(item.authoruri) + "\">" + htmlEncode(item.author) + "</a><br><span class=\"text-muted\">" + htmlEncode(new Date(item.published).toDateString()) + "</span></div>";
                FEED = $this;
            });

            $('#thumbs').html(thumbshtml);
        });
    }

    $('#add-channel').submit(function(e) {
        e.preventDefault();
        processing(1);
        $.ajax('/subscribe', {
            method: 'POST',
            data: { url: $('#url-input').val() },
            success: function(r) {
                if (r.error) {
                    alert(r.error);
                } else {
                    subs = r;
                    $('#url-input').val('');
                    redraw_subs();
                }
                processing(-1);
            },
            error: function(xhr) {
                alert("Error");
                processing(-1);
            },
        });
    });

    $('#clear-subs').submit(function(e) {
        e.preventDefault();
        processing(1);
        $.ajax('/clear-subs', {
            method: 'POST',
            success: function(r) {
                subs = r;
                redraw_subs();
                processing(-1);
            },
            error: function(xhr) {
                alert("Error");
                processing(-1);
            },
        });
    });

    fetch_subs();
});
