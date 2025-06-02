const Todo = require("../models/Todo");

exports.todo = async (req, res) => {
  try {
    const { text } = req.body;
    const todo = new Todo({ text, user: req.user.id });
    const savetodo = await todo.save();
    res.status(200).json(savetodo);
  } catch (error) {
    res
      .status(500)
      .json({ error: error.message, message: "Internal Server Error" });
  }
};

exports.gettodo = async (req, res) => {
  try {
    const todo = await Todo.find({ user: req.user.id });
    res.json(todo);
  } catch (error) {
    res.status(500).json({ message: "Server error , could not fetch todo" });
  }
};

exports.deletetodo = async (req, res) => {
  try {
    const { todoid } = req.params;
    const todo = await Todo.findOneAndDelete({
      _id: todoid,
      user: req.user.id,
    });
    if (!todo) {
      return res
        .status(404)
        .json({ message: `todo not found or unauthorized ` });
    }
    res.status(200).json({ message: "todo deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: "Server error, could not delete budget" });
  }
};

exports.updatetodo = async (req, res) => {
  try {
    const { todoid } = req.params;
    const { text } = req.body;
    const todo = await Todo.findOneAndUpdate(
      { _id: todoid, user: req.user.id },
      { text },
      { new: true, runvalidators: true }
    );
    if (!todo) {
      return res
        .status(404)
        .json({ message: "todo not found or unauthorized" });
    }
    res.status(200).json({ message: "todo updated successfully", todo });
  } catch (error) {
    res
      .status(500)
      .json({ message: `Server error, could not update todo ${error}` });
  }
};
