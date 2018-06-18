$(document).ready(function() {
    var subs = [];
    var running = 0;

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
        for (var i = 0; i < subs.length; i++) {
            ids.push(subs[i].channel_id);
        }
        url += ids.join(",");
        $('#feed-url').attr('href', url);
        $('#feed-url-span').text(url);

        if (ids.length > 0) {
            $('#current-subs').show();
        } else {
            $('#current-subs').hide();
        }
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
