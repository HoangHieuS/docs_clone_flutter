const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const authRouter = require("./routes/auth");

const PORT = process.env.PORT | 3001;

const app = express();

app.use(cors());
app.use(express.json());
app.use(authRouter);

const DB =
  "mongodb+srv://hoanghieu:hoanghieu179@cluster0.duk1k3i.mongodb.net/?retryWrites=true&w=majority";


mongoose
  .connect(DB)
  .then(() => {
    console.log("Connection successful!");
  })
  .catch((err) => {
    console.log(err);
  });

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server is running on port ${PORT}`);
});
