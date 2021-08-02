FlowRouter.template('/money_writing','money_writing');

Template.money_writing.onRendered(function () {

});

Template.money_writing.onDestroyed(function () {

});

Template.money_writing.events({
    'click #btn-money-save':function() {
        var user_id = Meteor.user()._id;
        var date = $('#inp-day').val();
        var time = $('#inp-time').val();
        var money = $('#inp-money').val();
        var option = $('#select-money').val();
        var text = $('#inp-money-text').val();
        var date_option = DB_DIARY.findOne({user_id: user_id,date:date});
        if(date_option)
        {
            DB_DIARY.update({_id:date_option._id},{
                $push:{
                    money:{
                        time: time,
                        money: money,
                        option: option,
                        text: text,
                    }
                }
            })
        }
        else{
            DB_DIARY.insert({
                date: date,
                user_id: user_id,
                diary:{},
                money:[{
                    time: time,
                    money: money,
                    option: option,
                    text: text,
                }]
            });
        }
        alert('가계부를 작성하였습니다.');
        FlowRouter.go('/diary');
    }
})