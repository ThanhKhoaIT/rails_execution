function AddMoreFile() {
  var fieldsHtml = $('#js-add-more-file').data('fields-html');
  var $fieldsHtml = $(fieldsHtml);
  var fileID = Date.now();
  $fieldsHtml.find('.file-name').attr('name', 'attachments[' + fileID + '][name]');
  $fieldsHtml.find('.file-upload').attr('name', 'attachments[' + fileID + '][file]');
  $('#attachment_files ul').append($fieldsHtml);
}
