<?php
class bd {
    protected $bbdd = "concierto";
    protected $username = "root";
    protected $password = "1234";
    protected $conexion;

    public function __construct() {
        try {
            $this->conexion = new PDO('mysql:host=db;dbname=' . $this->bbdd, $this->username, $this->password);
            
        } catch (PDOException $e) {
            echo 'Connection failed: ' . $e->getMessage();
            exit;
        }
    }
}
?>