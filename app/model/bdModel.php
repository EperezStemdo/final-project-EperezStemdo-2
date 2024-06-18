<?php
class bd {
    protected $bbdd = "concierto";
    protected $username = "adminuser";
    protected $password = "1234";
    protected $conexion;

    public function __construct() {
        try {
            $this->conexion = new PDO('mysql:host=10.0.1.4;dbname=' . $this->bbdd, $this->username, $this->password);
            
        } catch (PDOException $e) {
            echo 'Connection failed: ' . $e->getMessage();
            exit;
        }
    }
}
?>
