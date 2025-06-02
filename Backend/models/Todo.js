const mongoose = require('mongoose');

const todo = new mongoose.Schema({
    user:{type:mongoose.Schema.Types.ObjectId , ref:"User", required:true, index:true},
    text:{type:String , required:true},
    createdat:{type:Date , default:Date.now}
})

module.exports = mongoose.model("Todo",todo)