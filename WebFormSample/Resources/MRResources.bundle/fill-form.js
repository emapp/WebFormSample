(function ($, searchString) {
    var components = {
        $text : $("form#search_form input[type='text']"),
        $submit : $("form#search_form input[type='submit']")
    };

    components.$text.val(searchString);
    components.$submit.click();

    return JSON.stringify({
        "success" : true
    });
})(jQuery, '%@');