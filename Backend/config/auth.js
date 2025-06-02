const jwt = require('jsonwebtoken');
const User = require("../models/User");

const authmiddlewere=async (req,res,next)=>{
    const token = req.header('Authorization')?.split(" ")[1];
    if(!token){
        return res.status(401).json({messsage:"Unauthorized Token"})
    }
    try {
        const decode = jwt.verify(token ,process.env.JWT_SCT );
        req.user = await User.findById(decode.id).select("-password");

        if(!req.user){
            return res.status(401).json({
                messsage:"User Not Found"
            })
        }
        next();
    } catch (error) {
        if(error.name == "TokenExpiredError"){
            return res.status(401).json({
                message:"Token Has expired. Please login Again"
            })
        }else{
            return res.status(401).json({message:"Invalid token"})
        }
        
    }
}

module.exports=authmiddlewere;