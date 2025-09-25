<?php
    //Teste
    //Teste 2
    //Teste 3
    //Teste 4
    //Teste 5
    //Teste 6
    //Teste 7
    //Teste 8
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type");

    require_once "Conexao/Conexao.php";

    function semAcento($str) {
        return preg_match('/[À-ú]/', $str);
    }
    
    function verificasenhaForte($password) {
        // Defina os critérios de força de senha
        $minLength = 6; // Mínimo de 6 caracteres
        $maxLength = 20; // Máximo de 20 caracteres
        $requiresUppercase = true; // Deve conter letras maiúsculas
        $requiresNumber = true; // Deve conter pelo menos um número
        $requiresSpecialChar = true; // Deve conter caracteres especiais
    
        if (strlen($password) < $minLength || strlen($password) > $maxLength) {
            return true;
        }
    
        if ($requiresUppercase && !preg_match('/[A-Z]/', $password)) {
            return true;
        }
    
        if ($requiresNumber && !preg_match('/[0-9]/', $password)) {
            return true;
        }
    
        if ($requiresSpecialChar && !preg_match('/[!@#$%^&*()_+{}\[\]:;<>,.?~\\-=\\/]/', $password)) {
            return true;
        }
    
        return false;
    }

    try{

        //atributos para o recebimento de informações para o Flutter
        $usuarioNome = trim($_POST['usuarioNome']);
        $usuarioSenha = trim($_POST['usuarioSenha']);
        $novoUsuario = trim($_POST['name']);
        $usuarioEmail = trim($_POST['email']);
       

        //Verifica os campos em branco e comprimento minimo
        if(empty($usuarioNome) || empty($usuarioSenha) || empty($novoUsuario) || empty($usuarioEmail) ){
            $response = array("status" => "error", "message" => "Por favor, preencha todos os campos.");
            echo json_encode($response);
            exit;

        }

        if(strpos($usuarioNome, ' ') !== false || semAcento($usuarioNome) ){
            $response = array("status" => "error", "message" => "O nome do nome do usuário, não pode conter acentos ou espaços em branco.");
            echo json_encode($response);
            exit;

        }
        if(strpos($usuarioNome, ' ') !== false || strpos($usuarioSenha, ' ') !== false || strpos($novoUsuario, ' ') !== false || strpos($usuarioEmail, ' ') !== false ){
            $response = array("status" => "error", "message" => "nenhum dos campos deve ter um espaço em branco .");
            echo json_encode($response);
            exit;

        }

        //vertifica o comprimento máximo para o nome do Usuário
        $maximoComprimentoUsuario = 10; //Define o tamanho em 10
        if(strlen($usuarioNome) >$maximoComprimentoUsuario ){
            $response = array("status" => "error", "message" => "O nome não pode conter mais que .$maximoComprimentoUsuario. caracteres");
            echo json_encode($response);
            exit;
        }

        //Verifica o comprimento Mínimo para os Atributos
        if(strlen($usuarioNome) < 6 || strlen($usuarioSenha) < 6 || strlen($novoUsuario) < 6 ){
            $response = array("status" => "error", "message" => "Os camppos Nome, Senha e Novo Usuário devem conter mais que 6 caracteres");
            echo json_encode($response);
            exit;
        }

        //Verifica se a senha é Fraca
        if(verificasenhaForte($usuarioSenha)){
            $response = array("status" => "error", "message" => "A senha é Fraca, deve conter uma letra maiuscula e um caracter especial, Numero, não deve conter espaço em Branco");
            echo json_encode($response);
            exit;
        }

        //Gera um token unico para cada login
        $token = md5(uniqid(rand(), true));

        //Criptografar a senha com password_hash
        $usuarioSenhaNova = password_hash($usuarioSenha, PASSWORD_BCRYPT);

        //Verificar se o nome do usuário já está cadastrado no banco de dados
        $userNomeExisteQuery = "SELECT COUNT(*) as count FROM login WHERE username = :username";
        $usuarioExisteBanco = $conexao->prepare($userNomeExisteQuery);
        $usuarioExisteBanco -> bindParam(':username', $usuarioNome);
        $usuarioExisteBanco -> execute();
        $userNomeExisteResultado = $usuarioExisteBanco -> fetch(PDO::FETCH_ASSOC);
        
        //Verifica Usuario
        if($userNomeExisteResultado['count'] > 0){
            $response = array("status" => "error", "message" => "Este nome de Usuário já está em uso.");
            echo json_encode($response);
            exit;
        }

        //Validar e verificar email
        if(!filter_var($usuarioEmail, FILTER_VALIDATE_EMAIL) ){
            $response = array("status" => "error", "message" => "Formato de Email Inválido");
            echo json_encode($response);
            exit;
        }

        //Verifica no Banco de dados se o Email Existe
        $userEmailExisteQuery = "SELECT COUNT(*) as count FROM perfis WHERE email = :email";
        $emailExisteBanco = $conexao->prepare($userEmailExisteQuery);
        $emailExisteBanco -> bindParam(':email', $usuarioEmail);
        $emailExisteBanco -> execute();
        $usuarioEmailExisteResultado = $emailExisteBanco -> fetch(PDO::FETCH_ASSOC);
        
        //Verifica Email Existente no Banco
        if($usuarioEmailExisteResultado['count'] > 0){
            $response = array("status" => "error", "message" => "Este endereço de Email já está em uso.");
            echo json_encode($response);
            exit;
        }

        //Inserir Usuário no Banco de Dados
        $inseriUsuarioBanco = "INSERT INTO login (username, password, token, verified) VALUES (:username, :password, :token, 0)";
        $inseriBanco = $conexao->prepare($inseriUsuarioBanco);
        $inseriBanco -> bindParam(':username', $usuarioNome);
        $inseriBanco -> bindParam(':password', $usuarioSenhaNova);
        $inseriBanco -> bindParam(':token', $token);
        $inseriBanco -> execute();
        
        //Inserir id_usuario na Tabela perfis Recuperar o Id do Usuário
        $usuarioPerfil = $conexao->lastInsertId();

        //Atributos Nulos
        $novaLatitude = isset($_POST['latitude']) ? $_POST['latitude'] : NULL;
        $novaLongitude = isset($_POST['longitude']) ? $_POST['longitude'] : NULL;
        $novaRua = isset($_POST['rua']) ? $_POST['rua'] : NULL;

        //Inserir Dados de Perfil
        $inseriPerfilBanco = "INSERT INTO perfis (user_id, nome, email,latitude, longitude, rua) VALUES (:user_id, :nome, :email,:latitude, :longitude, :rua)";
        $inseriBanco = $conexao->prepare($inseriPerfilBanco);
        $inseriBanco -> bindParam(':user_id', $usuarioPerfil);
        $inseriBanco -> bindParam(':nome', $usuarioNome);
        $inseriBanco -> bindParam(':email', $usuarioEmail);
        $inseriBanco -> bindParam(':latitude', $novaLatitude);
        $inseriBanco -> bindParam(':longitude', $novaLongitude);
        $inseriBanco -> bindParam(':rua', $novaRua);
        $inseriBanco -> execute();
    
         //Envia Email de Confirmação de Cadastro
         require_once('envia-email/PHPMailer/class.phpmailer.php');

         // Envie o e-mail de confirmação
         $verificationLink = "https://www.florestasenegocios.com.br/aplicativo/brian/confirmar.php?token=$token&user_id=$userId";
     
         // Configurar o PHPMailer para enviar e-mail
         $Email = new PHPMailer();
         $Email->SetLanguage("br");
         $Email->IsSMTP(); // Habilita o SMTP 
         $Email->SMTPAuth = true; // Ativa e-mail autenticado
         $Email->Host = 'mail.florestasenegocios.com.br'; // Servidor de envio (verifique com sua hospedagem)
         $Email->Port = '587'; // Porta de envio (verifique com sua hospedagem)
         $Email->Username = 'contato@florestasenegocios.com.br'; // E-mail que será autenticado
         $Email->Password = 'paulocontato123@A'; // Senha do e-mail (substitua pela sua senha)
         // Ativa o envio de e-mails em HTML, se false, desativa.
         $Email->IsHTML(true);
         $Email->SMTPSecure = "sll"; // tls ou sll
         // E-mail do remetente da mensagem
         $Email->From = 'contato@florestasenegocios.com.br';
         // Nome do remetente do e-mail
         $Email->FromName = utf8_decode($newEmail);
         // Endereço de destino do e-mail, ou seja, para onde você quer que a mensagem do formulário vá?
         $Email->AddAddress($newEmail, $newName); // Para quem será enviada a mensagem
         // Informando no e-mail o assunto da mensagem
         $Email->Subject = utf8_decode("Confirmação de Cadastro Aplicativo");
         $Email->AddCC('contato@florestasenegocios.com.br', ''); // Copia
         //$Email->AddBCC('BRNEUKAMP@senacrs.com.br', 'MyTrash'); // Cópia Oculta
         $Email->Body = <<<body
         Seguem os dados para acesso ao Gerenciador do Sistema APP My Trash<br /><br />
         <strong>Nome:</strong> $newName<br />
         <strong>Email:</strong> $newEmail<br />
         <strong>Usuário:</strong> $newUsername<br />
         <strong>Obs:</strong> Você não precisa responder a este e-mail<br/>
         <a href="$verificationLink">Clique aqui para confirmar seu cadastro</a>
     body;
     
         // Verifica se está tudo ok com os parâmetros acima, se não, avisa do erro. Se sim, envia.
         if (!$Email->Send()) {
             echo '<div class="alert alert-danger">
                   <button type="button" class="close" data-dismiss="alert">×</button>
                   <strong>Erro ao enviar!</strong> Houve um problema ao enviar o e-mail de confirmação. Entre em contato com o administrador.
             </div>';
             echo "Erro: " . $Email->ErrorInfo;
         }

        // Retorne uma mensagem de sucesso
        $response = array("status" => "success", "message" => "Cadastro bem-sucedido. Verifique seu e-mail para confirmar.");
        echo json_encode($response);
    } catch (PDOException $e) {
        // Erro na conexão com o banco de dados
        $response = array("status" => "error", "message" => "Erro na conexão com o banco de dados" , $e);
        echo json_encode($response);
    }
    ?>
