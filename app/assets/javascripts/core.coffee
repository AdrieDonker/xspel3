# document ready actions
$ ->
  # Make elem with .click-this clickable to data-href
  $(document).on 'click', '.click-this', ->
    window.document.location = $(this).data('href')
    return
  return
 