window.EasyMDEs = {};

window.comments = {};
window.comments.clickEditComment = function(el) {
  $(el).hide();
  var $rootComment = $(el).closest('.media-comment');
  var commentKey = $rootComment.attr('id');

  $rootComment.toggleClass('editing');
  window.EasyMDEs[commentKey] ||= new EasyMDE({
    element: document.getElementById($rootComment.attr('id') + '_content'),
    status: false,
    maxHeight: '150px',
    showIcons: ['code'],
    spellChecker: false,
    placeholder: 'Type your comment here...',
    renderingConfig: {
      codeSyntaxHighlighting: true,
    }
  });
};
window.comments.initAddNewComment = function(id) {
  new EasyMDE({
    element: document.getElementById(id),
    status: false,
    maxHeight: '100px',
    showIcons: ['code'],
    spellChecker: false,
    placeholder: 'Type your comment here...',
    renderingConfig: {
      codeSyntaxHighlighting: true,
    }
  });
};
window.comments.renderMarkdown = function(commentKey) {
  var markdownEl = $(commentKey + " p.content-markdown");
  var htmlEl = $(commentKey + " p.content-html");
  markdownEl.hide();
  htmlEl.html(marked.parse(markdownEl.html()));
}
window.comments.cancelEditMode = function(cancelButton) {
  var $rootComment = $(cancelButton).closest('.media-comment');
  $rootComment.toggleClass('editing');
  $rootComment.find('.edit-comment').show();
}
