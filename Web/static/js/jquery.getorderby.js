$(function() {
    $.fn.getorderby = function() {
        var url = location.href;
        if(location.search) {
            param = url.split("?");
            params = param[1].split("&");

            var paramArray = [];
            for (i = 0; i < params.length; i++) {
                order = params[i].split("=");
                paramArray.push(order[0]);
                paramArray[order[0]] = order[1];
            };

            descby = paramArray["descby"];
            ascby = paramArray["ascby"];

            $('.' + descby + ".dsc").addClass("selected");
            $('.' + ascby + ".asc").addClass("selected");

        }
    }
});