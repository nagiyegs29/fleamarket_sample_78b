$(document).on('turbolinks:load', function(){
  $(function(){
    // カテゴリーセレクトボックスのオプションを作成
    // 変数を取得
    function appendOption(category){
      var html = `<option value="${category.id}" data-category="${category.id}">${category.name}</option>`;
      return html;
    }
    // 子カテゴリーの表示作成
    function appendChidrenBox(insertHTML){
      var childSelectHtml = '';
      childSelectHtml = `<div class="select--wrap__category__child" id = "children_wrapper">
                          <select id= child_category class="select--wrap__category__name" name=item[category_id]>
                            <option value="---" data-category="---">選択してください</option>
                            ${insertHTML}
                          </select>
                          <i class="fas fa-angle-down"></i>
                        </div>`
      $('.select--wrap__category').append(childSelectHtml);
    }

    // 孫カテゴリーの表示作成
    function appendGrandchidrenBox(insertHTML){
      var grandchildSelectHtml = '';
        // $('#children_wrapper').remove(); //親カテゴリーが初期値になった時、子以下を削除する
      grandchildSelectHtml = `<div class="select--wrap__category__grandchild" id = "grandchildren_wrapper">
                                <select id= grandchildren_category class="select--wrap__category__name" name=item[category_id]>
                                  <option value="---" data-category="---">選択してください</option>
                                  ${insertHTML}
                                </select>
                                <i class="fas fa-angle-down"></i>
                              </div>`
$('.select--wrap__category').append(grandchildSelectHtml);
    }

    // 親カテゴリー選択後のイベント
    $('#parent_category').on('change', function(){
      // documentは、開いているWebページのDOMツリーが入っているオブジェクト
      // .getElementById(“id名“)はDOMツリーから特定の要素を取得するためのメソッドの1つ
      var parent_category_id = document.getElementById('parent_category').value; //選択された親カテゴリーの名前を取得
      if (parent_category_id != "---"){ //親カテゴリーが初期値でないことを確認
        $.ajax({
          url: '/items/category/get_category_children',
          type: 'GET',
          data: { parent_id: parent_category_id },
          dataType: 'json'
        })
        .done(function(children){
          $('#children_wrapper').remove(); //親が変更された時、子以下を削除する
          $('#grandchildren_wrapper').remove();
          var insertHTML = '';
          children.forEach(function(child){
            insertHTML += appendOption(child);
          });
          appendChidrenBox(insertHTML);
        })
        .fail(function(){
          alert('カテゴリー取得に失敗しました');
        })
      }else{
        $('#children_wrapper').remove(); //親カテゴリーが初期値になった時、子以下を削除する
        $('#grandchildren_wrapper').remove();
      }
    });

    // 子カテゴリー選択後のイベント
    $('.select--wrap__category').on('change', '#child_category', function(){
      var child_category_id = $('#child_category option:selected').data('category'); 
      // console.log('test',child_category_id)
      //選択された子カテゴリーのidを取得
      if (child_category_id != "---"){ //子カテゴリーが初期値でないことを確認
        $.ajax({
          url: '/items/category/get_category_grandchildren',
          type: 'GET',
          data: { child_id: child_category_id },
          dataType: 'json'
        })
        .done(function(grandchildren){
          if (grandchildren.length != 0) {
            $('#grandchildren_wrapper').remove(); //子が変更された時、孫以下を削除する
            
            var insertHTML = '';
            grandchildren.forEach(function(grandchild){
              insertHTML += appendOption(grandchild);
            });
            appendGrandchidrenBox(insertHTML);
          }

        })
        .fail(function(){
          alert('カテゴリー取得に失敗しました');
        })
      }else{
        $('#grandchildren_wrapper').remove(); //子カテゴリーが初期値になった時、孫以下を削除する
      }
    });
  });
});