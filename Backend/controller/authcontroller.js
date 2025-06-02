const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.registeruser = async (req , res)=>{
    const {email , password} = req.body;
    try {
        if(!email || !password){
            return res.status(401).json({
                message:"All Fields are Required"
            });
        }
        const userexist = await User.findOne({email});
        if(userexist) return res.status(400).json({message:"User Already Exist"})

        const hashpassword = await bcrypt.hash(password , 10);
        const user = await User.create({email, password: hashpassword});
        res.status(201).json({message:"User Registerd Succesfully" , user});
    } catch (error) {
        res.status(500).json({error:error.message})
    }
}

exports.loginuser= async(req,res)=>{
    const {email, password} = req.body;

    try {
        const user = await User.findOne({email});
        if(!user) return res.status(400).json({message:"Invalid Credentials, pls Register"});

        const ismatch = await bcrypt.compare(password , user.password);
        if(!ismatch) return res.status(400).json({message:"Invalid Credentials , pls register"});

        const token = jwt.sign({id:user._id}, process.env.JWT_SCT, {expiresIn:"1h"});
        res.status(200).json({token , user});
    } catch (error) {
        res.status(500).json({error: error.message})
        
    }
}