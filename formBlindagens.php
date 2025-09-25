<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

require_once "../Conexao/Conexao.php";
require 'PHPMailer-master/src/PHPMailer.php';
require 'PHPMailer-master/src/SMTP.php';
require 'PHPMailer-master/src/Exception.php';
require 'PDF/fpdf.php'; // Incluindo a biblioteca FPDF

// Obtendo user_id e session_token do POST
$user_id = $_POST['user_id'] ?? null;
$session_token = $_POST['session_token'] ?? null;

// Verifica se os dados foram enviados corretamente
if (!$user_id || !$session_token) {
    echo json_encode(["status" => "error", "message" => "Dados ausentes"]);
    exit;
}

/*try {
    $token_result = $conexao->prepare("
        SELECT token, TIMESTAMPDIFF(SECOND, login_time, NOW()) AS session_duration 
        FROM session_token 
        WHERE user_id = :user_id 
        ORDER BY login_time DESC 
        LIMIT 1
    ");
    $token_result->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $token_result->execute();

    $token_data = $token_result->fetch(PDO::FETCH_ASSOC);

    if (!$token_data || $token_data['token'] !== $session_token || $token_data['session_duration'] >= 86400) {
        echo json_encode(["status" => "error", "message" => "Token inválido ou expirado"]);
        exit;
    }*/

        // Gera um número aleatório de até 10 caracteres
    // Gera um número aleatório de até 10 caracteres
    function gerarNumeroUnico($conexao) {
    do {
    // Gera um número aleatório de 19 dígitos
    $numeroUnico = '';
    while (strlen($numeroUnico) < 19) {
    $numeroUnico .= str_pad(mt_rand(0, 999999999), 9, '0', STR_PAD_LEFT);
    }
    $numeroUnico = substr($numeroUnico, 0, 19); // Garante exatamente 19 dígitos

    // Verifica se já existe no banco
    $stmt = $conexao->prepare("SELECT COUNT(*) FROM detonacao WHERE numero_unico = :numero_unico");
    $stmt->bindParam(':numero_unico', $numeroUnico, PDO::PARAM_STR);
    $stmt->execute();
    $existe = $stmt->fetchColumn();
    } while ($existe > 0); // Garante que o número é único

    return $numeroUnico;
    }

    // Chama a função para obter um número único
    $numeroUnico = gerarNumeroUnico($conexao);


function base64paraAssinaturas($base64_string, $output_file) {
    if (!preg_match('/^data:image\/(\w+);base64,/', $base64_string, $type)) {
        throw new Exception('Formato de Base64 inválido');
    }
    
    $data = explode(',', $base64_string);
    if (count($data) < 2) {
        throw new Exception('Dados Base64 incompletos');
    }
    
    $imageData = base64_decode($data[1]);
    if ($imageData === false) {
        throw new Exception('Falha ao decodificar Base64');
    }
    
    if (file_put_contents($output_file, $imageData) === false) {
        throw new Exception('Falha ao salvar a imagem');
    }
    
    return $output_file;
}

function base64paraImagens($imagensBase64)
{
 $savedImages = [];
 $errors = [];

 foreach ($imagensBase64 as $index => $base64String) {
 $filename = 'uploads/imagens/imagem_' . uniqid() . '.png'; // Nome do arquivo PNG
 $data = explode(',', $base64String); // Separar metadados do conteúdo Base64

 if (count($data) === 2 && base64_decode($data[1], true)) {
 $decodedData = base64_decode($data[1]);

 // Validar se o conteúdo é uma imagem PNG
 $image = imagecreatefromstring($decodedData);
 if ($image !== false) {
 // Salvar a imagem no formato PNG
 if (imagepng($image, $filename)) {
 $savedImages[] = $filename; // Adiciona à lista de imagens salvas
 } else {
 $errors[] = "Erro ao salvar a imagem $index.";
 }
 imagedestroy($image);
 } else {
 $errors[] = "Imagem $index inválida ou corrompida.";
 }
 } else {
 $errors[] = "Formato inválido para a imagem $index.";
 }
 }

 return [
 'success' => empty($errors),
 'saved_images' => $savedImages,
 'errors' => $errors,
 ];
}

function enviarResposta($status, $message, $dados = null) {
 $response = [
 'status' => $status,
 'message' => $message
 ];

 // Se houver dados adicionais, adicione ao array de resposta
 if ($dados !== null) {
 $response['dados'] = $dados;
 }

 // Enviar a resposta JSON
 echo json_encode($response);
 exit;
}

function gerarPDF($dados) {
    // Instanciando a classe FPDF
    $pdf = new FPDF();
    $pdf->AddPage();

    //cabeçalho
    $pdf->SetFont('Arial', '', 14);
    $pdf->Cell(0,10, utf8_decode('Anexo E'), 0, 1, 'C');
    $pdf->Cell(0,10, utf8_decode('Termo de fiscalização/vistoria de empresas que realizam atividades com'), 0,1 , 'C');
    $pdf->Cell(0,10, utf8_decode('blindagens balísticas e veículos blindados'), 0,1 , 'C');
    $pdf->ln(10);

    // Adicionando o logotipo no início do PDF
    // Caminho relativo ao script
    $logoPath = __DIR__ . '/../../logo.png'; // Volta duas pastas para localizar a imagem

    // Verifica se o arquivo existe
    if (file_exists($logoPath)) {
        $pdf->Image($logoPath, ($pdf->GetPageWidth() - 40) / 2, $pdf->GetY(), 40); // Centraliza o logotipo
        $pdf->Ln(50); // Espaçamento após o logotipo
    } else {
        $pdf->Cell(0, 10, utf8_decode('Logotipo não encontrado.'), 0, 1, 'C');
    }

$pdf->Ln(10);
$pdf->Ln(10);

    $pdf->Cell(0,10, utf8_decode('Ministério da defesa'), 0,1 , 'C');
    $pdf->Cell(0,10, utf8_decode('Exército Brasileiro'), 0,1 , 'C');
    $pdf->Cell(0,10, utf8_decode('Comando Militar do Sul'), 0,1 , 'C');
    $pdf->Cell(0,10, utf8_decode('Comando da 3ª Região Militar '), 0,1 , 'C');
    $pdf->Cell(0,10, utf8_decode('Serviço de Fiscalização de Produtos Controlados'), 0,1 , 'C');
    $pdf->ln();


    // Adicionando título
    $pdf->SetFont('Arial', 'BU', 12);
    $pdf->Cell(0, 10, utf8_decode('TERMO DE FISCALIZAÇÃO/VISTORIA DE EMPRESAS QUE REALIZAM ATIVIDADES COM'), 0, 1, 'C');
    $pdf->Cell(0, 10, utf8_decode('BLINDAGENS BALISTICAS E VEICULOS BLINDADOS'), 0, 1, 'C');

    // Número do termo, incluindo o número único gerado e a data
    $pdf->SetFont('Arial', '', 12); // Fonte padrão

     // Calcula o ponto de início centralizado
    $larguraTotal = $pdf->GetPageWidth();
    $pdf->SetX(($larguraTotal - 100) / 2); // Reduzindo a largura total ocupada

    // Texto fixo "Número"
    $pdf->Cell(15, 10, utf8_decode('Nº:'), 0, 0, 'C');

    // Número único em negrito
    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(25, 10, utf8_decode($dados['numeroUnico'] . ' / '), 0, 0, 'C');

    // Data atual em negrito
    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(25, 10, utf8_decode(date('d/m/Y')), 0, 0, 'C');

    // Texto fixo "/SFPC/3GAAE"
    $pdf->SetFont('Arial', '', 12);
    $pdf->Cell(30, 10, utf8_decode('/SFPC/3º GAAAe'), 0, 1, 'C');
    $pdf->Ln(10); // Espaçamento após a linha

    //Identificação do fiscalizado
    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(0, 10, utf8_decode('1.IDENTIFICAÇÃO FISCALIZADO '), 0, 1, 'L');

    // Dados da Empresa em duas colunas
    $campos = [
        'Razão Social' => $dados['razaoSocial'],
        'Email' => $dados['email'],
        'Data' => $dados['data'],
        'TR/CR' => $dados['trcr'],
        'Endereço' => $dados['endereco'],
        'Telefone' => $dados['telefone'],
        'Telefone Residencial' => $dados['telefoneResidencial'],
        'CNPJ' => $dados['cnpj'],
    ];

    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(40, 10, utf8_decode('Razão Social:'), 1, 0, 'L');
    $pdf->SetFont('Arial', '', 12);
    $pdf->MultiCell(150, 10, utf8_decode($dados['razaoSocial']), 1, 'L');
    $pdf->Ln(2); // Pequeno espaçamento

    // TR/CR e CNPJ (mesma linha, sem borda extra na resposta do CNPJ)
    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(40, 10, utf8_decode('TR/CR:'), 1, 0, 'L');
    $pdf->SetFont('Arial', '', 12);
    $pdf->Cell(55, 10, utf8_decode($dados['trcr']), 'TBL', 0, 'L'); // Apenas borda superior, esquerda e inferior

    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(20, 10, utf8_decode('CNPJ:'), 'TBL', 0, 'L'); // Apenas borda superior, esquerda e inferior
    $pdf->SetFont('Arial', '', 12);
    $pdf->Cell(75, 10, utf8_decode($dados['cnpj']), 'TBR', 1, 'L'); // Apenas borda superior, direita e inferior (sem borda extra na esquerda)
    $pdf->Ln(2); // Pequeno espaçamento

    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(40, 10, utf8_decode('Endereço:'), 1, 0, 'L');
    $pdf->SetFont('Arial', '', 12);
    $pdf->MultiCell(150, 10, utf8_decode($dados['endereco']), 1, 'L');
    $pdf->Ln(2); // Pequeno espaçamento

    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(40, 10, utf8_decode('Telefone:'), 1, 0, 'L');
    $pdf->SetFont('Arial', '', 12);
    $pdf->MultiCell(150, 10, utf8_decode($dados['telefone']), 1, 'L');
    $pdf->Ln(2); // Pequeno espaçamento

    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(40, 10, utf8_decode('Tel Residencial:'), 1, 0, 'L');
    $pdf->SetFont('Arial', '', 12);
    $pdf->MultiCell(150, 10, utf8_decode($dados['telefoneResidencial']), 1, 'L');
    $pdf->Ln(2); // Pequeno espaçamento


    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(40, 10, utf8_decode('Data:'), 1, 0, 'L');
    $pdf->SetFont('Arial', '', 12);
    $pdf->Cell(55, 10, utf8_decode($dados['data']), 'TBL', 0, 'L'); // Apenas borda superior, esquerda e inferior

    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(20, 10, utf8_decode('E-mail:'), 'TBL', 0, 'L'); // Apenas borda superior, esquerda e inferior
    $pdf->SetFont('Arial', '', 12);
    $pdf->Cell(75, 10, utf8_decode($dados['email']), 'TBR', 1, 'L'); // Apenas borda superior, direita e inferior (sem borda extra na esquerda)
    $pdf->Ln(2); // Pequeno espaçamento

     //Identificação do fiscalizado
    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(0, 10, utf8_decode('2.VERIFICAÇÃO DA EMPRESA'), 0, 1, 'L');

 //Identificação do fiscalizado
    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(0, 10, utf8_decode('a.Quanto às atividades e produtos '), 0, 1, 'L');

    //Colunas da Verificação numero Ordem| Itens verifica Sim|Não|Não se aplica
    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(20,10, utf8_decode("N° ORD"), 1, 0,'C');
    $pdf->Cell(60,10, utf8_decode("itens a verificar"), 1, 0,'C');
    $pdf->Cell(20,10, utf8_decode("SIM"), 1, 0,'C');
    $pdf->Cell(20,10, utf8_decode("NÃO"), 1, 0,'C');
    $pdf->Cell(30,10, utf8_decode("Não se Aplica"), 1, 0,'C');
    $pdf->Cell(40,10, utf8_decode("Observações"), 1, 1,'C');


   // Perguntas fixas
$perguntasFixasA = [
    "O TR/CR encontra-se ativo?",
    "Todas as atividades realizadas pela empresa estão apostiladas ao seu TR/CR?",
    "Todos os PCE encontram-se apostilados?",
    "Havendo armazenamento, as quantidades armazenadas encontram-se dentro dos limites autorizados na apostila ao TR/CR?",
];



// Loop através das respostas
foreach ($dados['respostas'] as $i => $resposta) {
    // Pegando a pergunta e observação
    $pergunta = $perguntasFixasA[$i] ?? 'Pergunta não definida';
    $observacao = $dados['observacoes'][$i] ?? 'Sem observação';

    if($pergunta == "Pergunta não definida" ){

        }else{

    // Calcule a altura das células
    $alturaPergunta = $pdf->GetStringWidth($pergunta) > 60 ? 40 : 10;
    $alturaObservacao = $pdf->GetStringWidth($observacao) > 40 ? 20 : 10;
    $alturaLinha = max($alturaPergunta, $alturaObservacao);

    // Número da Ordem
    $pdf->Cell(20, $alturaLinha, utf8_decode($i + 1), 1, 0, 'C');

    // Itens a Verificar
    $x = $pdf->GetX();
    $y = $pdf->GetY();
    $pdf->MultiCell(60, 5, utf8_decode($pergunta), 0, 'L'); // Sem borda
    $pdf->Rect($x, $y, 60, $alturaLinha); // Desenha a borda manualmente

    // Ajusta a posição para continuar na mesma linha
    $pdf->SetXY($x + 60, $y);

    // Respostas (SIM / NÃO / Não se aplica)
    $pdf->Cell(20, $alturaLinha, utf8_decode($resposta == 'Sim' ? 'X' : ''), 1, 0, 'C');
    $pdf->Cell(20, $alturaLinha, utf8_decode($resposta == 'Não' ? 'X' : ''), 1, 0, 'C');
    $pdf->Cell(30, $alturaLinha, utf8_decode($resposta == 'Não se Aplica' ? 'X' : ''), 1, 0, 'C');

    // Observações
    $x = $pdf->GetX();
    $y = $pdf->GetY();
    $pdf->MultiCell(40, 5, utf8_decode($observacao), 0, 'L');
    $pdf->Rect($x, $y, 40, $alturaLinha);

    // Vai para a próxima linha (sem espaço extra)
    $pdf->SetY($y + $alturaLinha);
        }
}

       //Identificação do fiscalizado
    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(0, 10, utf8_decode('b.Quanto à aplicação de blindagem balística automotiva (blindadoras)'), 0, 1, 'L');

    $perguntasFixasB = [    
        "A blindadora possui estrutura no endereço do registro para realizar a blindagem de veiculos?",
          "A blindadora possui Anotação de Responsabilidade Técnica (ART) ou Certidão de Registro de Pessoa Juridica válida?",
          "Todos os veiculos com a blindagem iniciada possuem Autorização de Blindagem?",
          "Todos os veículos cujos processos ainda não foram concluidos no SICOVAB estão nas instalações da blindadora?",
    ];
   foreach ($dados['respostas'] as $i => $resposta) {
    // Pegando a pergunta e observação
    $pergunta = $perguntasFixasB[$i] ?? 'Pergunta não definida';
    $observacao = $dados['observacoes'][$i] ?? 'Sem observação';

    if($pergunta == "Pergunta não definida" ){

        }else{

    // Calcule a altura das células
    $alturaPergunta = $pdf->GetStringWidth($pergunta) > 60 ? 40 : 10;
    $alturaObservacao = $pdf->GetStringWidth($observacao) > 40 ? 20 : 10;
    $alturaLinha = max($alturaPergunta, $alturaObservacao);

    // Número da Ordem
    $pdf->Cell(20, $alturaLinha, utf8_decode($i + 1), 1, 0, 'C');

    // Itens a Verificar
    $x = $pdf->GetX();
    $y = $pdf->GetY();
    $pdf->MultiCell(60, 5, utf8_decode($pergunta), 0, 'L'); // Sem borda
    $pdf->Rect($x, $y, 60, $alturaLinha); // Desenha a borda manualmente

    // Ajusta a posição para continuar na mesma linha
    $pdf->SetXY($x + 60, $y);

    // Respostas (SIM / NÃO / Não se aplica)
    $pdf->Cell(20, $alturaLinha, utf8_decode($resposta == 'Sim' ? 'X' : ''), 1, 0, 'C');
    $pdf->Cell(20, $alturaLinha, utf8_decode($resposta == 'Não' ? 'X' : ''), 1, 0, 'C');
    $pdf->Cell(30, $alturaLinha, utf8_decode($resposta == 'Não se Aplica' ? 'X' : ''), 1, 0, 'C');

    // Observações
    $x = $pdf->GetX();
    $y = $pdf->GetY();
    $pdf->MultiCell(40, 5, utf8_decode($observacao), 0, 'L');
    $pdf->Rect($x, $y, 40, $alturaLinha);

    // Vai para a próxima linha (sem espaço extra)
    $pdf->SetY($y + $alturaLinha);
        }
}
     //Identificação do fiscalizado
    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(0, 10, utf8_decode('c.Quanto à aplicação de blindagem balística em estruturas arquitetônicas'), 0, 1, 'L');

    $perguntasFixasC = [
        "A empresa possui estrutura no endereço do registro?",
          "A blindadora possui Anotação de Responsabilidade Técnica (ART) ou Certidão de Registro de Pessoa?",
          "Juridica válida? A empresa tem lançado a aplicação de blindagens balisticas no SICOVAB, conforme dispõe a ITA 21- DFPC/2019??",
          "A empresa tem lavrado 0 Termo De Responsabilidade de Aplicação de Blindagem Balistica (Anexo A2 da Portaria 94-COLOG/2019)?",

        // Adicione mais perguntas aqui
    ];
    foreach ($dados['respostas'] as $i => $resposta) {
    // Pegando a pergunta e observação
    $pergunta = $perguntasFixasC[$i] ?? 'Pergunta não definida';
    $observacao = $dados['observacoes'][$i] ?? 'Sem observação';

    if($pergunta == "Pergunta não definida" ){

        }else{

    // Calcule a altura das células
    $alturaPergunta = $pdf->GetStringWidth($pergunta) > 60 ? 40 : 10;
    $alturaObservacao = $pdf->GetStringWidth($observacao) > 40 ? 20 : 10;
    $alturaLinha = max($alturaPergunta, $alturaObservacao);

    // Número da Ordem
    $pdf->Cell(20, $alturaLinha, utf8_decode($i + 1), 1, 0, 'C');

    // Itens a Verificar
    $x = $pdf->GetX();
    $y = $pdf->GetY();
    $pdf->MultiCell(60, 5, utf8_decode($pergunta), 0, 'L'); // Sem borda
    $pdf->Rect($x, $y, 60, $alturaLinha); // Desenha a borda manualmente

    // Ajusta a posição para continuar na mesma linha
    $pdf->SetXY($x + 60, $y);

    // Respostas (SIM / NÃO / Não se aplica)
    $pdf->Cell(20, $alturaLinha, utf8_decode($resposta == 'Sim' ? 'X' : ''), 1, 0, 'C');
    $pdf->Cell(20, $alturaLinha, utf8_decode($resposta == 'Não' ? 'X' : ''), 1, 0, 'C');
    $pdf->Cell(30, $alturaLinha, utf8_decode($resposta == 'Não se Aplica' ? 'X' : ''), 1, 0, 'C');

    // Observações
    $x = $pdf->GetX();
    $y = $pdf->GetY();
    $pdf->MultiCell(40, 5, utf8_decode($observacao), 0, 'L');
    $pdf->Rect($x, $y, 40, $alturaLinha);

    // Vai para a próxima linha (sem espaço extra)
    $pdf->SetY($y + $alturaLinha);
        }
}
    $pdf->Ln(10);

    // Título "Informações sobre Infração"
    $pdf->SetFont('Arial', 'B', 14);
    $pdf->Cell(0, 10, utf8_decode('Informações sobre Infração'), 1, 1, 'L');
    $pdf->Ln(5);

    // Definição das larguras das colunas
    $larguraRotulo = 70;  // Largura fixa para os rótulos
    $larguraValor = 120;   // Largura para os valores (permitindo quebra de linha)
    $alturaLinha = 10;     // Altura da linha base
    $espacamento = 2;      // Espaçamento entre as linhas

    // Lista de campos que podem ter textos longos
    $camposMultilinha = ['Lista de Deficiências', 'Observações Gerais', 'Especificar Deficiências'];

    // Função para calcular a altura do MultiCell
    function getMultiCellHeight($pdf, $texto, $largura, $alturaLinha)
    {
        $numLinhas = $pdf->GetStringWidth($texto) / $largura;
        $numLinhas = ceil($numLinhas); // Arredonda para cima
        return max($alturaLinha, $numLinhas * $alturaLinha); // Retorna a altura mínima necessária
    }

// Informações sobre infração
$camposInfracao = [
    'Lista de Deficiências' => $dados['lista_deficiencia'],
    'Observações Gerais' => $dados['observacoes_gerais'],
    'Qtd Autos de Infração' => $dados['qtd_autos_infracao'],
    'Qtd Termos de Infração' => $dados['qtd_termos_aprensao'],
    'Qtd Termos Depositário' => $dados['qtd_termos_depositario'],
    'Especificar Deficiências' => $dados['especificar_deficiencias_encontradas'],
    'Prazo Deficiências' => $dados['prazo_deficiencias'],
    'Nome Fiscal Militar' => $dados['nome_fiscal_militar'],
];

foreach ($camposInfracao as $rotulo => $valor) {
    $pdf->SetFont('Arial', 'B', 12);
   
    // Calcula a altura da célula baseada no conteúdo
    if (in_array($rotulo, $camposMultilinha)) {
        $altura = getMultiCellHeight($pdf, $valor, $larguraValor, $alturaLinha);
    } else {
        $altura = $alturaLinha; // Usa a altura padrão
    }

    // Cria a célula do rótulo
    $pdf->Cell($larguraRotulo, $altura, utf8_decode($rotulo . ':'), 1, 0, 'L');

    // Cria a célula do valor com MultiCell
    $pdf->SetFont('Arial', '', 12);
    $x = $pdf->GetX();
    $y = $pdf->GetY();
    $pdf->MultiCell($larguraValor, $alturaLinha, utf8_decode($valor), 1, 'L');

    // Ajusta a posição para a próxima linha
    $pdf->SetXY($x + $larguraValor, $y + $altura);
    $pdf->Ln($espacamento);
}

    // Espaçamento antes das infrações
    $pdf->Ln(5);

    // Adicionando lista de infrações (se existirem)
    if (!empty($dados['infracao'])) {
        foreach ($dados['infracao'] as $infracao) {
            $pdf->SetFont('Arial', 'B', 12);
            $pdf->MultiCell(0, $alturaLinha, utf8_decode('Infração: ' . $infracao), 1, 'L');
        }
    }

    $pdf->Ln(10); // 1ª quebra
    $pdf->Ln(10); // 2ª quebra
    $pdf->Ln(10); // 3ª quebra

/*    // Informações sobre infrações
    $pdf->Cell(95, 10, utf8_decode('Qtd Autos de Infração: ' . $dados['qtd_autos_infracao']), 0, 0);
    $pdf->Cell(95, 10, utf8_decode('Qtd Termos de Infração: ' . $dados['qtd_termos_aprensao']), 0, 1);
    $pdf->Cell(95, 10, utf8_decode('Qtd Termos Depositário: ' . $dados['qtd_termos_depositario']), 0, 0);
    $pdf->Cell(95, 10, utf8_decode('Especificar Deficiências: ' . $dados['especificar_deficiencias_encontradas']), 0, 1);
    $pdf->Cell(95, 10, utf8_decode('Prazo Deficiências: ' . $dados['prazo_deficiencias']), 0, 0);
    $pdf->Cell(95, 10, utf8_decode('Nome Fiscal Militar: ' . $dados['nome_fiscal_militar']), 0, 1);
    $pdf->Cell(95, 10, utf8_decode('P/G Fiscal Militar: ' . $dados['fiscal_pg']), 0, 0);
    $pdf->Cell(95, 10, utf8_decode('Idt. Fiscal Militar: ' . $dados['idtmilitar']), 0, 1);
    $pdf->Cell(95, 10, utf8_decode('OM Fiscal Militar: ' . $dados['ommilitar']), 0, 0);
    $pdf->Cell(95, 10, utf8_decode('Empresa Fiscalizada: ' . $dados['nome_empresa']), 0, 1);
    $pdf->Cell(95, 10, utf8_decode('CPF Empresa: ' . $dados['cpf_empresa']), 0, 0);
    $pdf->Cell(95, 10, utf8_decode('Testemunha 1: ' . $dados['testemunha1']), 0, 1);
    $pdf->Cell(95, 10, utf8_decode('Idt Testemunha 1: ' . $dados['itdtestemunha1']), 0, 0);
    $pdf->Cell(95, 10, utf8_decode('Testemunha 2: ' . $dados['testemunha2']), 0, 1);
    $pdf->Cell(95, 10, utf8_decode('Idt Testemunha 2: ' . $dados['itdtestemunha2']), 0, 1);
*/
 // Adicionando título e imagens
$pdf->SetFont('Arial', 'B', 12);
$pdf->Cell(0, 10, utf8_decode('Imagens:'), 0, 1, 'C');
$pdf->Ln(5); // Espaçamento após o título


// Adicionando imagens
if (!empty($_POST['imagens'])) {
    $imagensBase64 = json_decode($_POST['imagens'], true);
    if (is_array($imagensBase64)) {
        $resultadoImagens = base64paraImagens($imagensBase64);
        if (!empty($resultadoImagens['saved_images'])) {
            $xPosition = 10;
            $yPosition = $pdf->GetY(); // Pega a posição Y atual após o título
            $maxWidth = 190; // Largura máxima disponível por linha
            $maxImagesPerRow = 5; // Máximo de imagens por linha
            $imageWidth = ($maxWidth - ($maxImagesPerRow - 1) * 5) / $maxImagesPerRow; // Calculando a largura das imagens para se ajustarem

            foreach ($resultadoImagens['saved_images'] as $index => $imagem) {
                if (file_exists($imagem)) {
                    $imageInfo = getimagesize($imagem);
                    if ($imageInfo !== false && $imageInfo[2] === IMAGETYPE_PNG) {
                        try {
                            // Ajustar a altura automaticamente para manter a proporção
                            $aspectRatio = $imageInfo[0] / $imageInfo[1]; // Largura / Altura da imagem original
                            $imageHeight = $imageWidth / $aspectRatio; // Calcula a altura proporcional

                            // Adicionar a imagem no PDF
                            $pdf->Image($imagem, $xPosition, $yPosition, $imageWidth, $imageHeight);

                            // Atualizar a posição para a próxima imagem
                            $xPosition += $imageWidth + 5; // 5 de espaçamento entre as imagens

                            // Quando atinge o limite de 5 imagens, começa uma nova linha
                            if (($index + 1) % $maxImagesPerRow === 0) {
                                $xPosition = 10; // Reinicia a posição horizontal
                                $yPosition += $imageHeight + 5; // Move para a próxima linha com base na altura da imagem
                            }

                            // Verificar se há espaço suficiente para as assinaturas, caso contrário, adicionar uma nova página
                            if ($yPosition + 50 > $pdf->getPageHeight()) {
                                $pdf->AddPage(); // Adiciona uma nova página se o espaço for insuficiente
                                $yPosition = 10; // Reseta a posição Y para o topo
                            }
                        } catch (Exception $e) {
                            $pdf->MultiCell(0, 10, "Erro ao inserir a imagem: " . $e->getMessage());
                        }
                    }
                }
            }
        }
    }
}


    $pdf->Ln(10); // 1ª quebra
    $pdf->Ln(10); // 2ª quebra
    $pdf->Ln(10); // 3ª quebra

    $pdf->Ln(10); // 1ª quebra
    $pdf->Ln(10); // 2ª quebra
    $pdf->Ln(10); // 3ª quebra

// Garantindo espaço suficiente para as assinaturas
$pdf->Ln(10); // Deixe um espaçamento extra após as imagens antes das assinaturas
$pdf->SetFont('Arial', 'B', 12);
$pdf->Cell(0, 10, utf8_decode('Assinaturas:'), 1, 1, 'C');
$pdf->Ln(5); // Pequeno espaçamento

// Continue com as assinaturas
$larguraTitulo = 60;
$larguraAssinatura = 90;
$alturaLinha = 10;
$alturaAssinatura = 40;
$alturaTexto = 8;
$alturaTotalAssinatura = $alturaAssinatura + (count($assinaturas[0]['campos_extras']) + 1) * $alturaTexto + 10; // Altura total estimada

// Dados das assinaturas
$assinaturas = [
    [
        "titulo" => "Fiscal Militar",
        "nome" => $dados['nome_fiscal_militar'],
        "campos_extras" => [
            "P/G" => $dados['fiscal_pg'],
            "IDT" => $dados['idtmilitar'],
            "OM" => $dados['ommilitar']
        ]
    ],
    [
        "titulo" => "Responsável Empresa",
        "nome" => $dados['nome_empresa'],
        "campos_extras" => [
            "CPF" => $dados['cpf_empresa']
        ]
    ],
    [
        "titulo" => "Testemunha 1",
        "nome" => $dados['testemunha1'],
        "campos_extras" => [
            "IDT" => $dados['itdtestemunha1']
        ]
    ],
    [
        "titulo" => "Testemunha 2",
        "nome" => $dados['testemunha2'],
        "campos_extras" => [
            "IDT" => $dados['itdtestemunha2']
        ]
    ]
];

// Processando assinaturas
foreach ($assinaturas as $i => $assinatura) {
    $campoAssinatura = 'assinatura' . ($i + 1);

    if (isset($dados[$campoAssinatura]) && !empty($dados[$campoAssinatura])) {
        try {
            $assinaturaImg = base64paraAssinaturas($dados[$campoAssinatura], 'PDF/FormulariosPDF/' . $campoAssinatura . '.png');

            // **Verifica se há espaço suficiente na página antes de adicionar a assinatura**
            if ($pdf->GetY() + $alturaTotalAssinatura > $pdf->GetPageHeight() - 20) {
                $pdf->AddPage();
                $pdf->Ln(10); // Pequeno espaçamento no topo da nova página
            }

            // Linha do título
            $pdf->SetFont('Arial', 'B', 12);
            $pdf->Cell(0, $alturaLinha, utf8_decode($assinatura['titulo']), 1, 1, 'C');

            // Linha da assinatura
            $posX = $pdf->GetX();
            $posY = $pdf->GetY();
            $pdf->Cell(0, $alturaAssinatura, '', 1, 1, 'C'); // Célula para a assinatura
            $pdf->Image($assinaturaImg, $posX + 40, $posY + 5, 60, 0);  // Ajuste fino da largura



            // Nome
            $pdf->SetFont('Arial', '', 12);
            $pdf->Cell(40, $alturaTexto, utf8_decode("Nome:"), 1, 0, 'L');
            $pdf->Cell(150, $alturaTexto, utf8_decode($assinatura['nome']), 1, 1, 'L');

            // Campos extras (P/G, IDT, OM ou CPF)
            foreach ($assinatura['campos_extras'] as $campo => $valor) {
                $pdf->Cell(40, $alturaTexto, utf8_decode($campo . ":"), 1, 0, 'L');
                $pdf->Cell(150, $alturaTexto, utf8_decode($valor), 1, 1, 'L');
            }

            $pdf->Ln(5); // Pequeno espaçamento entre as assinaturas

        } catch (Exception $e) {
            error_log('Erro ao processar a assinatura: ' . $e->getMessage());
        }
    }
}


    // Gerando nome do arquivo PDF com timestamp
    $timestamp = time();
    $nomeArquivo = 'blindagens_' . $dados['user_id'] . '_' . $timestamp . '.pdf';
    
    // Saída do PDF
    $pdf->Output('F', 'PDF/FormulariosPDF/' . $nomeArquivo); 
    return $nomeArquivo; 
}

try {
    // Receber dados
    $user_id = trim($_POST['user_id']);
    $razaoSocial = trim($_POST['razaoSocial']);
    $email = trim($_POST['email']);
    $data = trim($_POST['data']);
    $trcr = trim($_POST['trcr']);
    $endereco = trim($_POST['endereco']);
    $telefone = trim($_POST['telefone']);
    $telefoneResidencial = trim($_POST['telefoneResidencial']);
    $cnpj = trim($_POST['cnpj']);

    


        // Receber assinaturas (base64 ou URLs)
    $assinatura1 = $_POST['assinatura1'];
    $assinatura2 = $_POST['assinatura2'];
    $assinatura3 = $_POST['assinatura3'];
    $assinatura4 = $_POST['assinatura4'];

    //ENVIA INFORMAÇÕES DO ARRAY (EMPRESA E OBSERVAÇÕES)
    $respostas = json_decode($_POST['respostaEmpresa'] , true);
    $observacoes = json_decode($_POST['observacoes'], true);
    $user_id = json_decode($_POST['user_id'], true); 
    
    

    $lista_deficiencia = trim($_POST['lista_deficiencia']);
    $observacoes_gerais = trim($_POST['observacoes_gerais']);
    $qtd_autos_infracao = trim($_POST['qtd_autos_infracao']);
    $qtd_termos_aprensao = trim($_POST['qtd_termos_aprensao']);
    $qtd_termos_depositario = trim($_POST['qtd_termos_depositario']);
    $especificar_deficiencias_encontradas = trim($_POST['especificar_deficiencias_encontradas']);
    $prazo_deficiencias = trim($_POST['prazo_deficiencias']);

    $infracao = json_decode($_POST['infracao'], true);  


    $nome_fiscal_militar = trim($_POST['nome_fiscal_militar']);
    $fiscal_pg = trim($_POST['fiscal_pg']);
    $idtmilitar = trim($_POST['idtmilitar']);
    $ommilitar = trim($_POST['ommilitar']);
    $nome_empresa = trim($_POST['nome_empresa']);
    $cpf_empresa = trim($_POST['cpf_empresa']);
    $testemunha1 = trim($_POST['testemunha1']);
    $itdtestemunha1 = trim($_POST['itdtestemunha1']);
    $testemunha2 = trim($_POST['testemunha2']);
    $itdtestemunha2 = trim($_POST['itdtestemunha2']);
    $imagensBase64 = json_decode($_POST['imagens'], true);
    $listaApreensao = json_decode($_POST['listaApreensao'], true);
    $listaInfracao = json_decode($_POST['listaInfracao'], true);
     $listaInfracao = json_decode($_POST['listaDepositario'], true);

    
    // Log dos dados recebidos
    error_log(print_r($_POST, true));


    // Inicializa um array para armazenar as perguntas não preenchidas
    $naoPreenchidas = [];

    // Função para substituir valores nulos ou vazios por "Não se Aplica"
    function substituirPorNaoSeAplica(&$array) {
        foreach ($array as $indice => $valor) {
            if (is_null($valor) || $valor === '') {
                $array[$indice] = "Não se Aplica";
            }
        }
    }

    // Substitui valores vazios ou nulos nas observações e respostas por "Não se Aplica"
    substituirPorNaoSeAplica($observacoes);
    substituirPorNaoSeAplica($respostas);
    substituirPorNaoSeAplica($infracao);

    // Função para verificar se as respostas estão preenchidas
    function verificarPreenchimento($perguntas, $tipoPergunta) {
        global $naoPreenchidas;

        foreach ($perguntas as $indice => $resposta) {
            // Verifica se a resposta é nula, vazia ou não foi enviada
            if (is_null($resposta) || $resposta === '' || !isset($resposta)) {
                $naoPreenchidas[] = "Pergunta " . ($indice + 1) . " não foi preenchida ($tipoPergunta)";
            }
        }
    }

    // Verifica se as variáveis são arrays antes de chamar a função
    if (is_array($respostas)) {
        verificarPreenchimento($respostas, 'Verificação da Empresa (Sim) ou (Não)');
    } else {
        $naoPreenchidas[] = "Verificação da Empresa (Sim) ou (Não) não foi preenchida.";
    }

   
    // Verificação da infração
    if (is_array($infracao)) {
        verificarPreenchimento($infracao, 'Infração');
    } else {
        $naoPreenchidas[] = "Infração não foi preenchida.";
    }

    // Se houver perguntas não preenchidas, retorna um erro
    if (!empty($naoPreenchidas)) {
        // Juntar as mensagens em uma única string
        $mensagem = implode("\n", $naoPreenchidas);
        echo json_encode(["status" => "error", "message" => $mensagem]);
        exit;
    } 
    
   /* 
      // Verificar campos em branco
    if (empty($email)){
        echo json_encode(["status" => "error", "message" => "Campo Email em branco."]);
        exit;
    }
    if (empty($data)){
        echo json_encode(["status" => "error", "message" => "Campo Data em branco."]);
        exit;
    }
    if (empty($razaoSocial)){
        echo json_encode(["status" => "error", "message" => "Campo RazaoSocial em branco."]);
        exit;
    }
    if (empty($trcr)){
        echo json_encode(["status" => "error", "message" => "Campo TRCR em branco."]);
        exit;
    }
    if (empty($endereco)){
        echo json_encode(["status" => "error", "message" => "Campo Endereço em branco."]);
        exit;
    }
    if (empty($cnpj)){
        echo json_encode(["status" => "error", "message" => "Campo CNPJ em branco."]);
        exit;
    }
    if (empty($telefone)){
        echo json_encode(["status" => "error", "message" => "Campo Telefone em branco."]);
        exit;
    }
    if (empty($telefoneResidencial)){
        echo json_encode(["status" => "error", "message" => "Campo Telefone Residencial em branco."]);
        exit;
    }
    if (empty($lista_deficiencia)){
        echo json_encode(["status" => "error", "message" => "Campo Lista Deficiencia em branco."]);
        exit;
    }
    if (empty($observacoes_gerais)){
        echo json_encode(["status" => "error", "message" => "Campo Observações Gerais em branco."]);
        exit;
    }
    */
    if (empty($qtd_autos_infracao || $qtd_autos_infracao !== 0)){
        echo json_encode(["status" => "error", "message" => "Campo Qtd Autos Infração em branco."]);
        exit;
    }
    if (empty($qtd_termos_aprensao || $qtd_termos_aprensao !== 0 )){
        echo json_encode(["status" => "error", "message" => "Campo Qtd Termos Apreensão em branco."]);
        exit;
    }
    if (empty($qtd_termos_depositario || $qtd_termos_depositario !== 0)){
        echo json_encode(["status" => "error", "message" => "Campo Qtd Termos Depositário em branco."]);
        exit;
    }
    /*
    if (empty($especificar_deficiencias_encontradas)){
        echo json_encode(["status" => "error", "message" => "Campo Especificar Deficiencias Encontradas em branco."]);
        exit;
    }
    if (empty($prazo_deficiencias)){
        echo json_encode(["status" => "error", "message" => "Campo Prazo Deficiencias em branco."]);
        exit;
    }
    if (empty($nome_fiscal_militar)){
        echo json_encode(["status" => "error", "message" => "Campo Nome Fiscal Militar em branco."]);
        exit;
    }
    if (empty($idtmilitar)){
        echo json_encode(["status" => "error", "message" => "Campo IDT Militar em branco."]);
        exit;
    }
    if (empty($fiscal_pg)){
        echo json_encode(["status" => "error", "message" => "Campo Fiscal PG em branco."]);
        exit;
    }
    if (empty($ommilitar)){
        echo json_encode(["status" => "error", "message" => "Campo OM Militar em branco."]);
        exit;
    }
    if (empty($nome_empresa)){
        echo json_encode(["status" => "error", "message" => "Campo Nome Empresa em branco."]);
        exit;
    }
    if (empty($cpf_empresa)){
        echo json_encode(["status" => "error", "message" => "Campo CPF Empresa em branco."]);
        exit;
    }
    if (empty($testemunha1)){
        echo json_encode(["status" => "error", "message" => "Campo Nome Testemunha 1 em branco."]);
        exit;
    }
    if (empty($itdtestemunha1)){
        echo json_encode(["status" => "error", "message" => "Campo Itd Testemunha 1 em branco."]);
        exit;
    }
    if (empty($testemunha2)){
        echo json_encode(["status" => "error", "message" => "Campo Nome Testemunha 2 em branco."]);
        exit;
    }
    if (empty($itdtestemunha2)){
        echo json_encode(["status" => "error", "message" => "Campo Itd Testemunha 2 em branco."]);
        exit;
    }

    //Verificar tamanhos dos campos
    $maximoComprimentoCamposRazaoSocial = 200;
    if(strlen($razaoSocial) > $maximoComprimentoCamposRazaoSocial ){
        $response = array("status" => "error", "message" => "A Razão Social não pode conter mais que $maximoComprimentoCamposRazaoSocial caracteres");
        echo json_encode($response);
        exit;
    }
    $maximoComprimentoCamposTRCR = 200;
    if(strlen($trcr) > $maximoComprimentoCamposTRCR ){
        $response = array("status" => "error", "message" => "O TR/CR não pode conter mais que $maximoComprimentoCamposTRCR caracteres");
        echo json_encode($response);
        exit;
    }
    $maximoComprimentoCamposCnpj = 15; //Define o tamanho em 10
    if(strlen($cnpj) < $maximoComprimentoCamposCnpj ){
        $response = array("status" => "error", "message" => "O campo do CNPJ não pode conter mais que $maximoComprimentoCamposCnpj caracteres");
        echo json_encode($response);
        exit;
    }

    //Verificar tamanhos dos campos
    $maximoComprimentoCamposEndereco = 20; //Define o tamanho em 10
    if(strlen($endereco) > $maximoComprimentoCamposEndereco ){
        $response = array("status" => "error", "message" => "O campo Endereço não pode conter mais que $maximoComprimentoCamposEndereco caracteres");
        echo json_encode($response);
        exit;
    }
    //Verificar tamanhos dos campos
    $maximoComprimentoCamposTelefone = 11; //Define o tamanho em 10
    if(strlen($telefone) < $maximoComprimentoCamposTelefone ){
        $response = array("status" => "error", "message" => "O Campo do telefone não pode conter mais que $maximoComprimentoCamposTelefone caracteres");
        echo json_encode($response);
        exit;
    }
         //Verificar tamanhos dos campos
    $maximoComprimentoCamposTelefoneResi = 11; //Define o tamanho em 10
    if(strlen($telefoneResidencial) < $maximoComprimentoCamposTelefoneResi  ){
        $response = array("status" => "error", "message" => "O Campo do telefone reseidencial não pode conter mais que $maximoComprimentoCamposTelefoneResi caracteres");
        echo json_encode($response);
        exit;
    }
    $maximoComprimentoCampoEmail = 50;
    if(strlen($email) > $maximoComprimentoCampoEmail ){
        $response = array("status" => "error", "message" => "O Email não pode conter mais que $maximoComprimentoCampoEmail caracteres");
        echo json_encode($response);
        exit;
    }
    $maximoComprimentoCampoData = 10;
    if(strlen($data) < $maximoComprimentoCampoData ){
        $response = array("status" => "error", "message" => "O Campo data não pode conter menos que $maximoComprimentoCampoData caracteres");
        echo json_encode($response);
        exit;
    }
    
    $maximoComprimentoCampoDeficiencia = 200;
    if(strlen($lista_deficiencia) > $maximoComprimentoCampoDeficiencia ){
        $response = array("status" => "error", "message" => "O Campo Lista Deficiência não pode conter mais que $maximoComprimentoCampoDeficiencia caracteres");
        echo json_encode($response);
        exit;
    }
    $maximoComprimentoCampoOBSgerais = 200;
    if(strlen($observacoes_gerais) > $maximoComprimentoCampoOBSgerais ){
        $response = array("status" => "error", "message" => "O Campo Observações Gerais não pode conter mais que $maximoComprimentoCampoOBSgerais caracteres");
        echo json_encode($response);
        exit;
    }
    $maximoComprimentoCampoQtdAutoInfracao = 10;
    if(strlen($qtd_autos_infracao) > $maximoComprimentoCampoQtdAutoInfracao ){
        $response = array("status" => "error", "message" => "A Qtd Auto Infração não pode conter mais que $maximoComprimentoCampoQtdAutoInfracao caracteres");
        echo json_encode($response);
        exit;
    }
    $maximoComprimentoCampoQtdTermosApreensao = 10;
    if(strlen($qtd_termos_aprensao) > $maximoComprimentoCampoQtdTermosApreensao ){
        $response = array("status" => "error", "message" => "A Qtd Termos Apreensão não pode conter mais que $maximoComprimentoCampoQtdTermosApreensao caracteres");
        echo json_encode($response);
        exit;
    }
    $maximoComprimentoCampoQtdTermosFielDepositario = 10;
    if(strlen($qtd_termos_depositario) > $maximoComprimentoCampoQtdTermosFielDepositario ){
        $response = array("status" => "error", "message" => "A Qtd Termos Fiel Depositário não pode conter mais que $maximoComprimentoCampoQtdTermosFielDepositario caracteres");
        echo json_encode($response);
        exit;
    }
    $maximoComprimentoCampoEspecificarDef = 200;
    if(strlen($especificar_deficiencias_encontradas) > $maximoComprimentoCampoEspecificarDef ){
        $response = array("status" => "error", "message" => "O Campo Especificar Deficiências não pode conter mais que $maximoComprimentoCampoEspecificarDef caracteres");
        echo json_encode($response);
        exit;
    }
    $maximoComprimentoCampoPrazoDef = 10;
    if(strlen($prazo_deficiencias) > $maximoComprimentoCampoPrazoDef ){
        $response = array("status" => "error", "message" => "O Campo Prazo não pode conter mais que $maximoComprimentoCampoPrazoDef caracteres");
        echo json_encode($response);
        exit;
    }
    $maximoComprimentoCampoNomeFiscalMilitar = 20;
    if(strlen($nome_fiscal_militar) > $maximoComprimentoCampoNomeFiscalMilitar ){
        $response = array("status" => "error", "message" => "O Nome Fiscal Militar não pode conter mais que $maximoComprimentoCampoNomeFiscalMilitar caracteres");
        echo json_encode($response);
        exit;
    }
    $maximoComprimentoCampoIDTmilitar = 30;
    if(strlen($idtmilitar) > $maximoComprimentoCampoIDTmilitar ){
        $response = array("status" => "error", "message" => "O Campo IDT Militar não pode conter mais que $maximoComprimentoCampoIDTmilitar caracteres");
        echo json_encode($response);
        exit;
    }
    $maximoComprimentoCampoPG = 20;
    if(strlen($fiscal_pg) > $maximoComprimentoCampoPG ){
        $response = array("status" => "error", "message" => "O Campo PG não pode conter mais que $maximoComprimentoCampoPG caracteres");
        echo json_encode($response);
        exit;
    }   
    $maximoComprimentoCampoOM = 20;
    if(strlen($ommilitar) > $maximoComprimentoCampoOM ){
        $response = array("status" => "error", "message" => "O Campo OM Militar não pode conter mais que $maximoComprimentoCampoOM caracteres");
        echo json_encode($response);
        exit;
    } 
    $maximoComprimentoCampoNomeEmpresa = 20;
    if(strlen($nome_empresa) > $maximoComprimentoCampoNomeEmpresa ){
        $response = array("status" => "error", "message" => "O Campo Nome Empresa não pode conter mais que $maximoComprimentoCampoNomeEmpresa caracteres");
        echo json_encode($response);
        exit;
    }  
    $maximoComprimentoCampoCPFempresa = 14;
    if(strlen($cpf_empresa) > $maximoComprimentoCampoCPFempresa ){
        $response = array("status" => "error", "message" => "O Campo CPF Empresa não pode conter mais que $maximoComprimentoCampoCPFempresa caracteres");
        echo json_encode($response);
        exit;
    }
    $maximoComprimentoCampoTestemunha1Nome = 30;
    if(strlen($testemunha1) > $maximoComprimentoCampoTestemunha1Nome ){
        $response = array("status" => "error", "message" => "O Campo Nome Testemunha 1 não pode conter mais que $maximoComprimentoCampoTestemunha1Nome caracteres");
        echo json_encode($response);
        exit;
    } 
    $maximoComprimentoCampoTestemunha1ITD = 30;
    if(strlen($itdtestemunha1) > $maximoComprimentoCampoTestemunha1ITD ){
        $response = array("status" => "error", "message" => "O Campo ITD Militar Testemunha 1 não pode conter mais que $maximoComprimentoCampoTestemunha1ITD caracteres");
        echo json_encode($response);
        exit;
    }
    $maximoComprimentoCampoTestemunha2Nome = 30;
    if(strlen($testemunha2) > $maximoComprimentoCampoTestemunha2Nome ){
        $response = array("status" => "error", "message" => "O Campo Nome Testemunha 2 não pode conter mais que $maximoComprimentoCampoTestemunha2Nome caracteres");
        echo json_encode($response);
        exit;
    }
    $maximoComprimentoCampoTestemunha2ITD = 30;
    if(strlen($itdtestemunha2) > $maximoComprimentoCampoTestemunha2ITD ){
        $response = array("status" => "error", "message" => "O Campo ITD Militar Testemunha 2 não pode conter mais que $maximoComprimentoCampoTestemunha2ITD caracteres");
        echo json_encode($response);
        exit;
    }
    */

     $resultadoImagens = base64paraImagens($imagens_base64); 

    $imagensSalvas = [];
    if ($resultadoImagens['success']) {
    $imagensSalvas = $resultadoImagens['saved_images'];
    } else {
    // Log de erros para debug
    error_log("Erro ao processar imagens: " . implode(', ', $resultadoImagens['errors']));
    }

        // Recuperar o último número gerado após o INSERT
        $numeroUnicoInserido = $conexao->lastInsertId();

        // Gerar PDF
        $dadosPDF = [
        'user_id' => $user_id,
        'numeroUnico' => $numeroUnico,  // Passando o número único inserido
        'razaoSocial' => $razaoSocial,
        'email' => $email,
        'data' => $data,
        'trcr' => $trcr,
        'endereco' => $endereco,
        'telefone' => $telefone,
        'telefoneResidencial' => $telefoneResidencial,
        'cnpj' => $cnpj,
        'respostas' => $respostas,
        'observacoes' => $observacoes,
        'lista_deficiencia' => $lista_deficiencia,
        'observacoes_gerais' => $observacoes_gerais,
        'infracao' => $infracao,
        'qtd_autos_infracao' => $qtd_autos_infracao,
        'qtd_termos_aprensao' => $qtd_termos_aprensao,
        'qtd_termos_depositario' => $qtd_termos_depositario,
        'especificar_deficiencias_encontradas' => $especificar_deficiencias_encontradas,
        'prazo_deficiencias' => $prazo_deficiencias,
        'assinatura1' => $assinatura1,
        'assinatura2' => $assinatura2,
        'assinatura3' => $assinatura3,
        'assinatura4' => $assinatura4,

        'nome_fiscal_militar' => $nome_fiscal_militar,
        'fiscal_pg' => $fiscal_pg,
        'idtmilitar' => $idtmilitar,
        'ommilitar' => $ommilitar,
        'nome_empresa' => $nome_empresa,
        'cpf_empresa' => $cpf_empresa,
        'testemunha1' => $testemunha1,
        'itdtestemunha1' => $itdtestemunha1,
        'itdtestemunha2' => $itdtestemunha2,
        'testemunha2' => $testemunha2,
        'imagens' => $imagensSalvas,

    ];

    $nomeArquivoPDF = gerarPDF($dadosPDF);

    // Inserir no banco
$stmt = $conexao->prepare("INSERT INTO blindagens (user_id, razaoSocial, email, data, trcr, endereco, telefone, telefoneResidencial, cnpj, pdf_file) VALUES (:user_id, :razaoSocial, :email, :data, :trcr, :endereco, :telefone, :telefoneResidencial, :cnpj, :pdf_file)");
$stmt->bindParam(':user_id', $user_id);
$stmt->bindParam(':razaoSocial', $razaoSocial);
$stmt->bindParam(':email', $email);
$stmt->bindParam(':data', $data);
$stmt->bindParam(':trcr', $trcr);
$stmt->bindParam(':endereco', $endereco);
$stmt->bindParam(':telefone', $telefone);
$stmt->bindParam(':telefoneResidencial', $telefoneResidencial);
$stmt->bindParam(':cnpj', $cnpj);
$stmt->bindParam(':pdf_file', $nomeArquivoPDF);
$stmt->execute();

$blindagens_id = $conexao->lastInsertId();

$stmtRespostas = $conexao->prepare("INSERT INTO respostas_empresa_blindagens (blindagens_id, user_id, respostaEmpresa, observacoes) VALUES (:blindagens_id, :user_id, :respostaEmpresa, :observacoes)");
for ($i = 0; $i < count($respostas); $i++) {
    $stmtRespostas->bindParam(':user_id', $user_id);
    $stmtRespostas->bindParam(':blindagens_id', $blindagens_id);
    $stmtRespostas->bindValue(':respostaEmpresa', $respostas[$i]);
    $stmtRespostas->bindValue(':observacoes', $observacoes[$i]);
    $stmtRespostas->execute();
}





// Inserção na tabela deficiencias_observacoes_blindagens
$smtpinfracao = $conexao->prepare("INSERT INTO deficiencias_observacoes_blindagens (user_id, blindagens_id, lista_deficiencia, observacoes_gerais, infracao, qtd_autos_infracao, qtd_termos_aprensao, qtd_termos_depositario, especificar_deficiencias_encontradas, prazo_deficiencias, nome_fiscal_militar, fiscal_pg, idtmilitar, ommilitar, nome_empresa, cpf_empresa, testemunha1, itdtestemunha1, testemunha2, itdtestemunha2) VALUES (:user_id, :blindagens_id, :lista_deficiencia, :observacoes_gerais, :infracao, :qtd_autos_infracao, :qtd_termos_aprensao, :qtd_termos_depositario, :especificar_deficiencias_encontradas, :prazo_deficiencias, :nome_fiscal_militar, :fiscal_pg, :idtmilitar, :ommilitar, :nome_empresa, :cpf_empresa, :testemunha1, :itdtestemunha1, :testemunha2, :itdtestemunha2)");

// Bind dos parâmetros fora do loop
$smtpinfracao->bindParam(':user_id', $user_id);
$smtpinfracao->bindParam(':blindagens_id', $blindagens_id);
$smtpinfracao->bindParam(':lista_deficiencia', $lista_deficiencia);
$smtpinfracao->bindParam(':observacoes_gerais', $observacoes_gerais);
$smtpinfracao->bindParam(':qtd_autos_infracao', $qtd_autos_infracao);
$smtpinfracao->bindParam(':qtd_termos_aprensao', $qtd_termos_aprensao);
$smtpinfracao->bindParam(':qtd_termos_depositario', $qtd_termos_depositario);
$smtpinfracao->bindParam(':especificar_deficiencias_encontradas', $especificar_deficiencias_encontradas);
$smtpinfracao->bindParam(':prazo_deficiencias', $prazo_deficiencias);
$smtpinfracao->bindParam(':nome_fiscal_militar', $nome_fiscal_militar);
$smtpinfracao->bindParam(':fiscal_pg', $fiscal_pg);
$smtpinfracao->bindParam(':idtmilitar', $idtmilitar);
$smtpinfracao->bindParam(':ommilitar', $ommilitar);
$smtpinfracao->bindParam(':nome_empresa', $nome_empresa);
$smtpinfracao->bindParam(':cpf_empresa', $cpf_empresa);
$smtpinfracao->bindParam(':testemunha1', $testemunha1);
$smtpinfracao->bindParam(':itdtestemunha1', $itdtestemunha1);
$smtpinfracao->bindParam(':testemunha2', $testemunha2);
$smtpinfracao->bindParam(':itdtestemunha2', $itdtestemunha2);

for ($i = 0; $i < count($infracao); $i++) {
    $smtpinfracao->bindValue(':infracao', $infracao[$i]);
    $smtpinfracao->execute();
}



$listaApreensao = isset($_POST['listaApreensao']) ? json_decode($_POST['listaApreensao'], true) : null;

if (!is_array($listaApreensao) || empty($listaApreensao)) {
    error_log("Nenhuma apreensão enviada ou JSON inválido.");
} else {
    // Preparar a query de inserção
    $stmt = $conexao->prepare("INSERT INTO blindagens_apreensao (blindagens_id, data_hora, estadoIdSelecionado, cidade, produto, qtdApreensao, unidade, tipo, marca, obs) 
                               VALUES (:blindagens_id, :data_hora, :estadoIdSelecionado, :cidade, :produto, :qtdApreensao, :unidade, :tipo, :marca, :obs)");

    foreach ($listaApreensao as $apreensao) {
        $data_hora = isset($apreensao['data_hora']) ? trim($apreensao['data_hora']) : null;
        $estadoIdSelecionado = isset($apreensao['estadoIdSelecionado']) ? intval($apreensao['estadoIdSelecionado']) : null;
        $cidade = isset($apreensao['cidade']) ? trim($apreensao['cidade']) : null;

        if (!empty($data_hora) && !empty($estadoIdSelecionado) && !empty($cidade)) {
            // Agora iteramos sobre a lista de produtos
            if (!empty($apreensao['produtos']) && is_array($apreensao['produtos'])) {
                foreach ($apreensao['produtos'] as $produto) {
                    $produtoNome = isset($produto['produto']) ? trim($produto['produto']) : null;
                    $qtdApreensao = isset($produto['qtdApreensao']) ? trim($produto['qtdApreensao']) : null;
                    $unidade = isset($produto['unidade']) ? trim($produto['unidade']) : null;
                    $tipo = isset($produto['tipo']) ? trim($produto['tipo']) : null;
                    $marca = isset($produto['marca']) ? trim($produto['marca']) : null;
                    $obs = isset($produto['obs']) ? trim($produto['obs']) : null;

                    if (!empty($produtoNome)) {
                        $stmt->bindParam(':blindagens_id', $blindagens_id, PDO::PARAM_INT);
                        $stmt->bindParam(':data_hora', $data_hora, PDO::PARAM_STR);
                        $stmt->bindParam(':estadoIdSelecionado', $estadoIdSelecionado, PDO::PARAM_INT);
                        $stmt->bindParam(':cidade', $cidade, PDO::PARAM_STR);
                        $stmt->bindParam(':produto', $produtoNome, PDO::PARAM_STR);
                        $stmt->bindParam(':qtdApreensao', $qtdApreensao, PDO::PARAM_STR);
                        $stmt->bindParam(':unidade', $unidade, PDO::PARAM_STR);
                        $stmt->bindParam(':tipo', $tipo, PDO::PARAM_STR);
                        $stmt->bindParam(':marca', $marca, PDO::PARAM_STR);
                        $stmt->bindParam(':obs', $obs, PDO::PARAM_STR);
                        $stmt->execute();
                    }
                }
            }
        }
    }
}

function gerarPDFListaApreensao($dados) {
    // Mapeamento de estados
    $estados = [
        1 => 'Acre', 2 => 'Alagoas', 3 => 'Amapá', 4 => 'Amazonas', 5 => 'Bahia', 6 => 'Ceará',
        7 => 'Distrito Federal', 8 => 'Espírito Santo', 9 => 'Goiás', 10 => 'Maranhão',
        11 => 'Mato Grosso', 12 => 'Mato Grosso do Sul', 13 => 'Minas Gerais', 14 => 'Pará',
        15 => 'Paraíba', 16 => 'Paraná', 17 => 'Pernambuco', 18 => 'Piauí', 19 => 'Rio de Janeiro',
        20 => 'Rio Grande do Norte', 21 => 'Rio Grande do Sul', 22 => 'Rondônia', 23 => 'Roraima',
        24 => 'Santa Catarina', 25 => 'São Paulo', 26 => 'Sergipe', 27 => 'Tocantins'
    ];

        // Instanciando a classe FPDF
        $pdf = new FPDF();

        foreach ($dados['listaApreensao'] as $apreensao) {
                $pdf->AddPage();
                $pdf->SetFont('Times', '', 12);

                // Cabeçalho do termo
                $pdf->SetFont('Times', '', 14);
                $pdf->Cell(0, 10, utf8_decode('Anexo "M"'), 0, 1, 'C');
                $pdf->Cell(0, 10, utf8_decode('Termo de Apreensão'), 0, 1, 'C');


                // Caminho relativo ao logotipo
                $logoPath = __DIR__ . '/../../logo.png';
                if (file_exists($logoPath)) {
                    $pdf->Image($logoPath, ($pdf->GetPageWidth() - 20) / 2, $pdf->GetY(), 20);
                    $pdf->Ln(30);
                }
                $pdf->Ln(10);

                // Número do termo, incluindo o número único gerado e a data
                $pdf->SetFont('Times', '', 12); // Fonte padrão

                // Calcula o ponto de início centralizado
                $larguraTotal = $pdf->GetPageWidth(); 
                $pdf->SetX(($larguraTotal - 100) / 2); // Reduzindo a largura total ocupada

                // Texto fixo "Número"
                $pdf->Cell(20, 10, utf8_decode('Nº'), 0, 0, 'C');

                // Número único em negrito
                $pdf->SetFont('Times', 'B', 12);
                $pdf->Cell(50, 10, utf8_decode($dados['numeroUnico'] . ' / '), 0, 0, 'C');

                // Data atual em negrito
                $pdf->SetFont('Times', 'B', 12);
                $pdf->Cell(25, 10, utf8_decode(date('d/m/Y')), 0, 0, 'C');

                // Texto fixo "/SFPC/3GAAE"
                $pdf->SetFont('Times', '', 12);
                $pdf->Cell(25, 10, utf8_decode('/SFPC/3º GAAAe'), 0, 1, 'C');

                $pdf->Ln(10); // Espaçamento após a linha

                // Obtendo os valores corretos
                $estadoId = isset($apreensao['estadoIdSelecionado']) ? intval($apreensao['estadoIdSelecionado']) : null;
                $estadoNome = isset($estados[$estadoId]) ? $estados[$estadoId] : 'N/A';

                // Extração correta dos valores de data e hora
                $data_hora = isset($apreensao['data_hora']) ? $apreensao['data_hora'] : 'N/A';
                $partes_data = explode('-', $data_hora);
                
                // Definir padrões se os valores não existirem
                $ano = isset($partes_data[0]) ? $partes_data[0] : 'N/A';
                $mes = isset($partes_data[1]) ? $partes_data[1] : 'N/A';
                $dia = isset($partes_data[2]) ? explode(' ', $partes_data[2])[0] : 'N/A';
                $hora = isset(explode(' ', $data_hora)[1]) ? explode(' ', $data_hora)[1] : 'N/A';

                // Cidade
                $cidade = isset($apreensao['cidade']) ? $apreensao['cidade'] : 'N/A';

        // Texto do Auto de Infração
        $pdf->SetFont('Times', '', 12);
        $pdf->MultiCell(0, 10, utf8_decode(
            "Às " . $hora . " horas do dia " . $dia . " do mês de " . $mes . " do ano de " . $ano . ", " .
            "no Estado " . $estadoNome . ", na cidade de " . $cidade . ", tendo verificado os indícios de " .
            "irregularidades constantes do Ofício de Notificação/Auto de Infração, procedi à apreensão dos " .
            "Produtos Controlados pelo Exército a seguir especificados, de acordo com o art. 127 do Regulamento de Produtos Controlados (Decreto no 10.030, de 30 de setembro de 2019) que se encontravam em situação de suposta irregularidade cometida no trato com PCE conforme relatado em Ofício de Notificação/Auto de Infração:"
        ));
        $pdf->Ln(10);

        // Cabeçalho da tabela
        $pdf->SetFont('Times', 'B', 12);
        $pdf->Cell(30, 10, utf8_decode('Produto'), 1, 0, 'C');
        $pdf->Cell(20, 10, utf8_decode('Qtd'), 1, 0, 'C');
        $pdf->Cell(20, 10, utf8_decode('Unidade'), 1, 0, 'C');
        $pdf->Cell(30, 10, utf8_decode('Tipo'), 1, 0, 'C');
        $pdf->Cell(30, 10, utf8_decode('Marca'), 1, 0, 'C');
        $pdf->Cell(50, 10, utf8_decode('Observação'), 1, 1, 'C');

        $pdf->SetFont('Times', '', 12);
        foreach ($apreensao['produtos'] as $produto) {
            $pdf->Cell(30, 10, utf8_decode($produto['produto']), 1, 0, 'C');
            $pdf->Cell(20, 10, utf8_decode($produto['qtdApreensao']), 1, 0, 'C');
            $pdf->Cell(20, 10, utf8_decode($produto['unidade']), 1, 0, 'C');
            $pdf->Cell(30, 10, utf8_decode($produto['tipo']), 1, 0, 'C');
            $pdf->Cell(30, 10, utf8_decode($produto['marca']), 1, 0, 'C');
            $pdf->Cell(50, 10, utf8_decode($produto['obs']), 1, 1, 'C');
        }
    }


     // Garantindo espaço suficiente para as assinaturas
    $pdf->Ln(10); // Deixe um espaçamento extra após as imagens antes das assinaturas
    $pdf->SetFont('Times', 'B', 12);
    $pdf->Cell(0, 10, utf8_decode('Assinaturas:'), 1, 1, 'C');
    $pdf->Ln(5); // Pequeno espaçamento


    // Continue com as assinaturas
    $larguraTitulo = 60;
    $larguraAssinatura = 90;
    $alturaLinha = 10;
    $alturaAssinatura = 40;
    $alturaTexto = 8;
    $alturaTotalAssinatura = $alturaAssinatura + (count($assinaturas[0]['campos_extras']) + 1) * $alturaTexto + 10; // Altura total estimada


        $dados = [
    // Assinaturas
    'assinatura1' => $_POST['assinatura1'] ?? '',
    'assinatura2' => $_POST['assinatura2'] ?? '',
    'assinatura3' => $_POST['assinatura3'] ?? '',
    'assinatura4' => $_POST['assinatura4'] ?? '',

    // Dados do Fiscal Militar
    'nome_fiscal_militar' => trim($_POST['nome_fiscal_militar'] ?? ''),
    'fiscal_pg' => trim($_POST['fiscal_pg'] ?? ''),
    'idtmilitar' => trim($_POST['idtmilitar'] ?? ''),
    'ommilitar' => trim($_POST['ommilitar'] ?? ''),

    // Dados da Empresa
    'nome_empresa' => trim($_POST['nome_empresa'] ?? ''),
    'cpf_empresa' => trim($_POST['cpf_empresa'] ?? ''),

    // Testemunhas
    'testemunha1' => trim($_POST['testemunha1'] ?? ''),
    'itdtestemunha1' => trim($_POST['itdtestemunha1'] ?? ''),
    'testemunha2' => trim($_POST['testemunha2'] ?? ''),
    'itdtestemunha2' => trim($_POST['itdtestemunha2'] ?? '')
];


    // Dados das assinaturas
    $assinaturas = [
        [
            "titulo" => "Fiscal Militar",
            "nome" => $dados['nome_fiscal_militar'],
            "campos_extras" => [
                "P/G" => $dados['fiscal_pg'],
                "IDT" => $dados['idtmilitar'],
                "OM" => $dados['ommilitar']
            ]
        ],
        [
            "titulo" => "Proprietário ou Responsável Empresa",
            "nome" => $dados['nome_empresa'],
            "campos_extras" => [
                "CPF" => $dados['cpf_empresa']
            ]
        ],
        [
            "titulo" => "Testemunha 1",
            "nome" => $dados['testemunha1'],
            "campos_extras" => [
                "IDT" => $dados['itdtestemunha1']
            ]
        ],
        [
            "titulo" => "Testemunha 2",
            "nome" => $dados['testemunha2'],
            "campos_extras" => [
                "IDT" => $dados['itdtestemunha2']
            ]
        ]
    ];

    // Processando assinaturas
    foreach ($assinaturas as $i => $assinatura) {
        $campoAssinatura = 'assinatura' . ($i + 1);

        if (isset($dados[$campoAssinatura]) && !empty($dados[$campoAssinatura])) {
            try {
                $assinaturaImg = base64paraAssinaturas($dados[$campoAssinatura], 'PDF/FormulariosPDF/' . $campoAssinatura . '.png');

                // **Verifica se há espaço suficiente na página antes de adicionar a assinatura**
                if ($pdf->GetY() + $alturaTotalAssinatura > $pdf->GetPageHeight() - 20) {
                    $pdf->AddPage();
                    $pdf->Ln(10); // Pequeno espaçamento no topo da nova página
                }

                // Linha do título
                $pdf->SetFont('Times', 'B', 12);
                $pdf->Cell(0, $alturaLinha, utf8_decode($assinatura['titulo']), 1, 1, 'C');

                // Linha da assinatura
                $posX = $pdf->GetX();
                $posY = $pdf->GetY();
                $pdf->Cell(0, $alturaAssinatura, '', 1, 1, 'C'); // Célula para a assinatura
                $pdf->Image($assinaturaImg, $posX + 40, $posY + 5, 60, 0);  // Ajuste fino da largura

                // Nome
                $pdf->SetFont('Times', '', 12);
                $pdf->Cell(40, $alturaTexto, utf8_decode("Nome:"), 1, 0, 'L');
                $pdf->Cell(150, $alturaTexto, utf8_decode($assinatura['nome']), 1, 1, 'L');

                // Campos extras (P/G, IDT, OM ou CPF)
                foreach ($assinatura['campos_extras'] as $campo => $valor) {
                    $pdf->Cell(40, $alturaTexto, utf8_decode($campo . ":"), 1, 0, 'L');
                    $pdf->Cell(150, $alturaTexto, utf8_decode($valor), 1, 1, 'L');
                }

                $pdf->Ln(5); // Pequeno espaçamento entre as assinaturas

            } catch (Exception $e) {
                error_log('Erro ao processar a assinatura: ' . $e->getMessage());
            }
        }
    }


    $pdf->MultiCell(0, 10, utf8_decode("Em caso de Recusa do Infrator em assinar o auto de Apreensão ou Infrator não encontrado. É valido as assinatura acima do Fiscal Militar e das Testemunhas."));
    $pdf->Ln(5); // Pequeno espaçamento

    // Gerando nome do arquivo
    $timestamp = time();
    $nomeArquivo = 'lista_apreensao_' . $dados['user_id'] . '_' . $timestamp . '.pdf';
    
    // Saída do PDF
    $pdf->Output('F', 'PDF/FormulariosPDF/' . $nomeArquivo);
    return $nomeArquivo;
}


// Verificar se 'listaApreensao' foi enviada e se é um JSON válido
$listaApreensao = isset($_POST['listaApreensao']) ? json_decode($_POST['listaApreensao'], true) : null;

if (is_array($listaApreensao) && !empty($listaApreensao)) {
    $dadosPDFLista = [
        'user_id' => $user_id,
        'numeroUnico' => $numeroUnico,
        'listaApreensao' => $listaApreensao,
    ];
    $nomeArquivoPDFLista = gerarPDFListaApreensao($dadosPDFLista);
}

// Infracao
$listaInfracao = isset($_POST['listaInfracao']) ? json_decode($_POST['listaInfracao'], true) : null;

if (!is_array($listaInfracao) || empty($listaInfracao)) {
    error_log("Nenhuma infração enviada ou JSON inválido.");
} else {
    // Preparar a query de inserção
    $stmt = $conexao->prepare("INSERT INTO blindagens_infracao 
        (blindagens_id, data_hora_infracao, estadoIdSelecionado_infracao, cidade_infracao, 
        produto_infracao, qtdApreensao_infracao, unidade_infracao, tipo_infracao, marca_infracao, obs_infracao) 
        VALUES 
        (:blindagens_id, :data_hora_infracao, :estadoIdSelecionado_infracao, :cidade_infracao, 
        :produto_infracao, :qtdApreensao_infracao, :unidade_infracao, :tipo_infracao, :marca_infracao, :obs_infracao)");

    foreach ($listaInfracao as $infracao) {
        $data_hora_infracao = isset($infracao['data_hora_infracao']) ? trim($infracao['data_hora_infracao']) : null;
        $estadoIdSelecionado_infracao = isset($infracao['estadoIdSelecionado_infracao']) ? intval($infracao['estadoIdSelecionado_infracao']) : null;
        $cidade_infracao = isset($infracao['cidade_infracao']) ? trim($infracao['cidade_infracao']) : null;

        if (!empty($data_hora_infracao) && !empty($estadoIdSelecionado_infracao) && !empty($cidade_infracao)) {
            // Agora iteramos sobre a lista de produtos da infração
            if (!empty($infracao['produtos_infracao']) && is_array($infracao['produtos_infracao'])) {
                foreach ($infracao['produtos_infracao'] as $produto) {
                    $produto_infracao = isset($produto['produto_infracao']) ? trim($produto['produto_infracao']) : null;
                    $qtdApreensao_infracao = isset($produto['qtdApreensao_infracao']) ? trim($produto['qtdApreensao_infracao']) : null;
                    $unidade_infracao = isset($produto['unidade_infracao']) ? trim($produto['unidade_infracao']) : null;
                    $tipo_infracao = isset($produto['tipo_infracao']) ? trim($produto['tipo_infracao']) : null;
                    $marca_infracao = isset($produto['marca_infracao']) ? trim($produto['marca_infracao']) : null;
                    $obs_infracao = isset($produto['obs_infracao']) ? trim($produto['obs_infracao']) : null;

                    if (!empty($produto_infracao)) {
                        $stmt->bindParam(':blindagens_id', $blindagens_id, PDO::PARAM_INT);
                        $stmt->bindParam(':data_hora_infracao', $data_hora_infracao, PDO::PARAM_STR);
                        $stmt->bindParam(':estadoIdSelecionado_infracao', $estadoIdSelecionado_infracao, PDO::PARAM_INT);
                        $stmt->bindParam(':cidade_infracao', $cidade_infracao, PDO::PARAM_STR);
                        $stmt->bindParam(':produto_infracao', $produto_infracao, PDO::PARAM_STR);
                        $stmt->bindParam(':qtdApreensao_infracao', $qtdApreensao_infracao, PDO::PARAM_STR);
                        $stmt->bindParam(':unidade_infracao', $unidade_infracao, PDO::PARAM_STR);
                        $stmt->bindParam(':tipo_infracao', $tipo_infracao, PDO::PARAM_STR);
                        $stmt->bindParam(':marca_infracao', $marca_infracao, PDO::PARAM_STR);
                        $stmt->bindParam(':obs_infracao', $obs_infracao, PDO::PARAM_STR);
                        $stmt->execute();
                    }
                }
            }
        }
    }
}


function gerarPDFListaInfracao($dados) {

        // Instanciando a classe FPDF
    $pdf = new FPDF();
    // Mapeamento de estados
    $estados = [
        1 => 'Acre', 2 => 'Alagoas', 3 => 'Amapá', 4 => 'Amazonas', 5 => 'Bahia', 6 => 'Ceará',
        7 => 'Distrito Federal', 8 => 'Espírito Santo', 9 => 'Goiás', 10 => 'Maranhão',
        11 => 'Mato Grosso', 12 => 'Mato Grosso do Sul', 13 => 'Minas Gerais', 14 => 'Pará',
        15 => 'Paraíba', 16 => 'Paraná', 17 => 'Pernambuco', 18 => 'Piauí', 19 => 'Rio de Janeiro',
        20 => 'Rio Grande do Norte', 21 => 'Rio Grande do Sul', 22 => 'Rondônia', 23 => 'Roraima',
        24 => 'Santa Catarina', 25 => 'São Paulo', 26 => 'Sergipe', 27 => 'Tocantins'
    ];



     // Mapeamento de estados
    $estados = [
        1 => 'Acre', 2 => 'Alagoas', 3 => 'Amapá', 4 => 'Amazonas', 5 => 'Bahia', 6 => 'Ceará',
        7 => 'Distrito Federal', 8 => 'Espírito Santo', 9 => 'Goiás', 10 => 'Maranhão',
        11 => 'Mato Grosso', 12 => 'Mato Grosso do Sul', 13 => 'Minas Gerais', 14 => 'Pará',
        15 => 'Paraíba', 16 => 'Paraná', 17 => 'Pernambuco', 18 => 'Piauí', 19 => 'Rio de Janeiro',
        20 => 'Rio Grande do Norte', 21 => 'Rio Grande do Sul', 22 => 'Rondônia', 23 => 'Roraima',
        24 => 'Santa Catarina', 25 => 'São Paulo', 26 => 'Sergipe', 27 => 'Tocantins'
    ];

        // Instanciando a classe FPDF
        $pdf = new FPDF();

        foreach ($dados['listaInfracao'] as $infracao) {
                $pdf->AddPage();
                $pdf->SetFont('Times', '', 12);

                // Cabeçalho do termo
                $pdf->SetFont('Times', '', 14);
                $pdf->Cell(0, 10, utf8_decode('Anexo "M"'), 0, 1, 'C');
                $pdf->Cell(0, 10, utf8_decode('Termo de Infração'), 0, 1, 'C');


                // Caminho relativo ao logotipo
                $logoPath = __DIR__ . '/../../logo.png';
                if (file_exists($logoPath)) {
                    $pdf->Image($logoPath, ($pdf->GetPageWidth() - 20) / 2, $pdf->GetY(), 20);
                    $pdf->Ln(30);
                }
                $pdf->Ln(10);

                // Número do termo, incluindo o número único gerado e a data
                $pdf->SetFont('Times', '', 12); // Fonte padrão

                // Calcula o ponto de início centralizado
                $larguraTotal = $pdf->GetPageWidth(); 
                $pdf->SetX(($larguraTotal - 100) / 2); // Reduzindo a largura total ocupada

                // Texto fixo "Número"
                $pdf->Cell(20, 10, utf8_decode('Nº'), 0, 0, 'C');

                // Número único em negrito
                $pdf->SetFont('Times', 'B', 12);
                $pdf->Cell(50, 10, utf8_decode($dados['numeroUnico'] . ' / '), 0, 0, 'C');

                // Data atual em negrito
                $pdf->SetFont('Times', 'B', 12);
                $pdf->Cell(25, 10, utf8_decode(date('d/m/Y')), 0, 0, 'C');

                // Texto fixo "/SFPC/3GAAE"
                $pdf->SetFont('Times', '', 12);
                $pdf->Cell(25, 10, utf8_decode('/SFPC/3º GAAAe'), 0, 1, 'C');

                $pdf->Ln(10); // Espaçamento após a linha

                // Obtendo os valores corretos
                $estadoId = isset($infracao['estadoIdSelecionado_infracao']) ? intval($infracao['estadoIdSelecionado_infracao']) : null;
                $estadoNome = isset($estados[$estadoId]) ? $estados[$estadoId] : 'N/A';

                // Extração correta dos valores de data e hora
                $data_hora = isset($infracao['data_hora_infracao']) ? $infracao['data_hora_infracao'] : 'N/A';
                $partes_data = explode('-', $data_hora);
                
                // Definir padrões se os valores não existirem
                $ano = isset($partes_data[0]) ? $partes_data[0] : 'N/A';
                $mes = isset($partes_data[1]) ? $partes_data[1] : 'N/A';
                $dia = isset($partes_data[2]) ? explode(' ', $partes_data[2])[0] : 'N/A';
                $hora = isset(explode(' ', $data_hora)[1]) ? explode(' ', $data_hora)[1] : 'N/A';

                // Cidade
                $cidade = isset($infracao['cidade']) ? $infracao['cidade'] : 'N/A';

        // Texto do Auto de Infração
        $pdf->SetFont('Times', '', 12);
        $pdf->MultiCell(0, 10, utf8_decode(
            "Às " . $hora . " horas do dia " . $dia . " do mês de " . $mes . " do ano de " . $ano . ", " .
            "no Estado " . $estadoNome . ", na cidade de " . $cidade . ", tendo verificado os indícios de " .
            "irregularidades constantes do Ofício de Notificação/Auto de Infração, procedi à apreensão dos " .
            "Produtos Controlados pelo Exército a seguir especificados, de acordo com o art. 127 do Regulamento de Produtos Controlados (Decreto no 10.030, de 30 de setembro de 2019) que se encontravam em situação de suposta irregularidade cometida no trato com PCE conforme relatado em Ofício de Notificação/Auto de Infração:"
        ));
        $pdf->Ln(10);



    }


        $pdf->MultiCell(0, 10, utf8_decode("Foram verificados os seguintes indícios de irregularidade(s):\n\n(Descrever as irregularidades encontradas)"));
        $pdf->Ln(5);
   
        $pdf->MultiCell(0, 10, utf8_decode("" . $lista_deficiencia));
        $pdf->Ln(5);

        $pdf->MultiCell(0, 10, utf8_decode("Os quais poderão constituir infração(oes), capitulada(s) no Decreto 10.030 (Regulamento de Produtos Controlados). Para constar, lavrei o presente auto em 2 (duas) vias, uma das quais foi entregue ao autuado/notificado/representante, por mim assinada:\n"));

        $pdf->Ln(5);
        $pdf->MultiCell(0, 10, utf8_decode("Fiscal Militar do Serviço de Fiscalização de Produtos Controlados do 3º GAAAe"));
        $pdf->MultiCell(0, 10, utf8_decode("Nome do Fiscal Militar: " . $nome_fiscal_militar));
        $pdf->MultiCell(0, 10, utf8_decode("Posto/Graduação: " . $fiscal_pg));
        $pdf->MultiCell(0, 10, utf8_decode("IDT Militar: " . $idtmilitar));
        $pdf->Ln(5);

        $pdf->MultiCell(0, 10, utf8_decode("Assinado também pelo autuado (ou seu preposto ou representante legal), ao qual é concedido o prazo de 15 (quinze) dias, a contar da presente data, para apresentação de Defesa Prévia, nos termos do § 1º, do artigo 26, da Portaria nº 42-COLOG, de 27 de fevereiro de 2020 (Dispõe sobre os procedimentos relativos ao Processo Administrativo Sancionador no Âmbito do Sistema de Fiscalização de Produtos Controlados - SisFPC)."));
        $pdf->Ln(5);

          // Garantindo espaço suficiente para as assinaturas
    $pdf->Ln(10); // Deixe um espaçamento extra após as imagens antes das assinaturas
    $pdf->SetFont('Times', 'B', 12);
    $pdf->Cell(0, 10, utf8_decode('Assinaturas:'), 1, 1, 'C');
    $pdf->Ln(5); // Pequeno espaçamento


    // Continue com as assinaturas
    $larguraTitulo = 60;
    $larguraAssinatura = 90;
    $alturaLinha = 10;
    $alturaAssinatura = 40;
    $alturaTexto = 8;
    $alturaTotalAssinatura = $alturaAssinatura + (count($assinaturas[0]['campos_extras']) + 1) * $alturaTexto + 10; // Altura total estimada


        $dados = [
    // Assinaturas
    'assinatura1' => $_POST['assinatura1'] ?? '',
    'assinatura2' => $_POST['assinatura2'] ?? '',
    'assinatura3' => $_POST['assinatura3'] ?? '',
    'assinatura4' => $_POST['assinatura4'] ?? '',

    // Dados do Fiscal Militar
    'nome_fiscal_militar' => trim($_POST['nome_fiscal_militar'] ?? ''),
    'fiscal_pg' => trim($_POST['fiscal_pg'] ?? ''),
    'idtmilitar' => trim($_POST['idtmilitar'] ?? ''),
    'ommilitar' => trim($_POST['ommilitar'] ?? ''),

    // Dados da Empresa
    'nome_empresa' => trim($_POST['nome_empresa'] ?? ''),
    'cpf_empresa' => trim($_POST['cpf_empresa'] ?? ''),

    // Testemunhas
    'testemunha1' => trim($_POST['testemunha1'] ?? ''),
    'itdtestemunha1' => trim($_POST['itdtestemunha1'] ?? ''),
    'testemunha2' => trim($_POST['testemunha2'] ?? ''),
    'itdtestemunha2' => trim($_POST['itdtestemunha2'] ?? '')
];


    // Dados das assinaturas
    $assinaturas = [
        [
            "titulo" => "Fiscal Militar",
            "nome" => $dados['nome_fiscal_militar'],
            "campos_extras" => [
                "P/G" => $dados['fiscal_pg'],
                "IDT" => $dados['idtmilitar'],
                "OM" => $dados['ommilitar']
            ]
        ],
        [
            "titulo" => "Proprietário ou Responsável Empresa",
            "nome" => $dados['nome_empresa'],
            "campos_extras" => [
                "CPF" => $dados['cpf_empresa']
            ]
        ],
        [
            "titulo" => "Testemunha 1",
            "nome" => $dados['testemunha1'],
            "campos_extras" => [
                "IDT" => $dados['itdtestemunha1']
            ]
        ],
        [
            "titulo" => "Testemunha 2",
            "nome" => $dados['testemunha2'],
            "campos_extras" => [
                "IDT" => $dados['itdtestemunha2']
            ]
        ]
    ];

    // Processando assinaturas
    foreach ($assinaturas as $i => $assinatura) {
        $campoAssinatura = 'assinatura' . ($i + 1);

        if (isset($dados[$campoAssinatura]) && !empty($dados[$campoAssinatura])) {
            try {
                $assinaturaImg = base64paraAssinaturas($dados[$campoAssinatura], 'PDF/FormulariosPDF/' . $campoAssinatura . '.png');

                // **Verifica se há espaço suficiente na página antes de adicionar a assinatura**
                if ($pdf->GetY() + $alturaTotalAssinatura > $pdf->GetPageHeight() - 20) {
                    $pdf->AddPage();
                    $pdf->Ln(10); // Pequeno espaçamento no topo da nova página
                }

                // Linha do título
                $pdf->SetFont('Times', 'B', 12);
                $pdf->Cell(0, $alturaLinha, utf8_decode($assinatura['titulo']), 1, 1, 'C');

                // Linha da assinatura
                $posX = $pdf->GetX();
                $posY = $pdf->GetY();
                $pdf->Cell(0, $alturaAssinatura, '', 1, 1, 'C'); // Célula para a assinatura
                $pdf->Image($assinaturaImg, $posX + 40, $posY + 5, 60, 0);  // Ajuste fino da largura

                // Nome
                $pdf->SetFont('Times', '', 12);
                $pdf->Cell(40, $alturaTexto, utf8_decode("Nome:"), 1, 0, 'L');
                $pdf->Cell(150, $alturaTexto, utf8_decode($assinatura['nome']), 1, 1, 'L');

                // Campos extras (P/G, IDT, OM ou CPF)
                foreach ($assinatura['campos_extras'] as $campo => $valor) {
                    $pdf->Cell(40, $alturaTexto, utf8_decode($campo . ":"), 1, 0, 'L');
                    $pdf->Cell(150, $alturaTexto, utf8_decode($valor), 1, 1, 'L');
                }

                $pdf->Ln(5); // Pequeno espaçamento entre as assinaturas

            } catch (Exception $e) {
                error_log('Erro ao processar a assinatura: ' . $e->getMessage());
            }
        }
    }

        $pdf->MultiCell(0, 10, utf8_decode("A defesa deverá ser dirigida ao Sr. Comandante do 3º GAAAe, através do email: vistoria.sfpc@3gaaae.eb.mil.br."));





   


    $pdf->MultiCell(0, 10, utf8_decode("Em caso de Recusa do Infrator em assinar o auto de Infração ou Infrator não encontrado. É valido as assinatura acima do Fiscal Militar e das Testemunhas"));
    $pdf->Ln(5); // Pequeno espaçamento

    // Gerando nome do arquivo
    $timestamp = time();
    $nomeArquivo = 'lista_infracao_' . $dados['user_id'] . '_' . $timestamp . '.pdf';
    
    // Saída do PDF
    $pdf->Output('F', 'PDF/FormulariosPDF/' . $nomeArquivo);
    return $nomeArquivo;
}
// Verificar se 'listaInfracao' foi enviada e se é um JSON válido
$listaInfracao = isset($_POST['listaInfracao']) ? json_decode($_POST['listaInfracao'], true) : null;

if (is_array($listaInfracao) && !empty($listaInfracao)) {
    $dadosPDFLista = [
        'user_id' => $user_id,
        'numeroUnico' => $numeroUnico,
        'listaInfracao' => $listaInfracao,
    ];
    $nomeArquivoPDFListaInfracao = gerarPDFListaInfracao($dadosPDFLista);
}

//Termo de Fiel Depositário

// Fiel Depositário
$listaDepositario = isset($_POST['listaDepositario']) ? json_decode($_POST['listaDepositario'], true) : null;

if (!is_array($listaDepositario) || empty($listaDepositario)) {
    error_log("Nenhum fiel depositário enviado ou JSON inválido.");
} else {
    // Preparar a query de inserção
    $stmt = $conexao->prepare("INSERT INTO blindagens_fiel_depositario 
        (blindagens_id, data_hora_depositario, estadoIdSelecionado_depositario, cidade_depositario, 
        produto_depositario, qtdApreensao_depositario, unidade_depositario, tipo_depositario, 
        marca_depositario, obs_depositario) 
        VALUES 
        (:blindagens_id, :data_hora_depositario, :estadoIdSelecionado_depositario, :cidade_depositario, 
        :produto_depositario, :qtdApreensao_depositario, :unidade_depositario, :tipo_depositario, 
        :marca_depositario, :obs_depositario)");

    foreach ($listaDepositario as $depositario) {
        $data_hora_depositario = isset($depositario['data_hora_depositario']) ? trim($depositario['data_hora_depositario']) : null;
        $estadoIdSelecionado_depositario = isset($depositario['estadoIdSelecionado_depositario']) ? intval($depositario['estadoIdSelecionado_depositario']) : null;
        $cidade_depositario = isset($depositario['cidade_depositario']) ? trim($depositario['cidade_depositario']) : null;

        if (!empty($data_hora_depositario) && !empty($estadoIdSelecionado_depositario) && !empty($cidade_depositario)) {
            // Itera sobre a lista de produtos do fiel depositário
            if (!empty($depositario['produtos_depositario']) && is_array($depositario['produtos_depositario'])) {
                foreach ($depositario['produtos_depositario'] as $produto) {
                    $produto_depositario = isset($produto['produto_depositario']) ? trim($produto['produto_depositario']) : null;
                    $qtdApreensao_depositario = isset($produto['qtdApreensao_depositario']) ? trim($produto['qtdApreensao_depositario']) : null;
                    $unidade_depositario = isset($produto['unidade_depositario']) ? trim($produto['unidade_depositario']) : null;
                    $tipo_depositario = isset($produto['tipo_depositario']) ? trim($produto['tipo_depositario']) : null;
                    $marca_depositario = isset($produto['marca_depositario']) ? trim($produto['marca_depositario']) : null;
                    $obs_depositario = isset($produto['obs_depositario']) ? trim($produto['obs_depositario']) : null;

                    if (!empty($produto_depositario)) {
                        $stmt->bindParam(':blindagens_id', $blindagens_id, PDO::PARAM_INT);
                        $stmt->bindParam(':data_hora_depositario', $data_hora_depositario, PDO::PARAM_STR);
                        $stmt->bindParam(':estadoIdSelecionado_depositario', $estadoIdSelecionado_depositario, PDO::PARAM_INT);
                        $stmt->bindParam(':cidade_depositario', $cidade_depositario, PDO::PARAM_STR);
                        $stmt->bindParam(':produto_depositario', $produto_depositario, PDO::PARAM_STR);
                        $stmt->bindParam(':qtdApreensao_depositario', $qtdApreensao_depositario, PDO::PARAM_STR);
                        $stmt->bindParam(':unidade_depositario', $unidade_depositario, PDO::PARAM_STR);
                        $stmt->bindParam(':tipo_depositario', $tipo_depositario, PDO::PARAM_STR);
                        $stmt->bindParam(':marca_depositario', $marca_depositario, PDO::PARAM_STR);
                        $stmt->bindParam(':obs_depositario', $obs_depositario, PDO::PARAM_STR);
                        $stmt->execute();
                    }
                }
            }
        }
    }
}

function gerarPDFFielDepositario($dados) {
    // Mapeamento de estados
    $estados = [
        1 => 'Acre', 2 => 'Alagoas', 3 => 'Amapá', 4 => 'Amazonas', 5 => 'Bahia', 6 => 'Ceará',
        7 => 'Distrito Federal', 8 => 'Espírito Santo', 9 => 'Goiás', 10 => 'Maranhão',
        11 => 'Mato Grosso', 12 => 'Mato Grosso do Sul', 13 => 'Minas Gerais', 14 => 'Pará',
        15 => 'Paraíba', 16 => 'Paraná', 17 => 'Pernambuco', 18 => 'Piauí', 19 => 'Rio de Janeiro',
        20 => 'Rio Grande do Norte', 21 => 'Rio Grande do Sul', 22 => 'Rondônia', 23 => 'Roraima',
        24 => 'Santa Catarina', 25 => 'São Paulo', 26 => 'Sergipe', 27 => 'Tocantins'
    ];

    // Instanciando a classe FPDF
    $pdf = new FPDF();

    foreach ($dados['listaDepositario'] as $depositario) {
                $pdf->AddPage();
                $pdf->SetFont('Times', '', 12);

                // Cabeçalho do termo
                $pdf->SetFont('Times', '', 14);
                $pdf->Cell(0, 10, utf8_decode('Anexo "N"'), 0, 1, 'C');
                $pdf->Cell(0, 10, utf8_decode('Termo de Fiel Depositario'), 0, 1, 'C');


                // Caminho relativo ao logotipo
                $logoPath = __DIR__ . '/../../logo.png';
                if (file_exists($logoPath)) {
                    $pdf->Image($logoPath, ($pdf->GetPageWidth() - 20) / 2, $pdf->GetY(), 20);
                    $pdf->Ln(30);
                }
                $pdf->Ln(10);

                // Número do termo, incluindo o número único gerado e a data
                $pdf->SetFont('Times', '', 12); // Fonte padrão

                // Calcula o ponto de início centralizado
                $larguraTotal = $pdf->GetPageWidth(); 
                $pdf->SetX(($larguraTotal - 100) / 2); // Reduzindo a largura total ocupada

                // Texto fixo "Número"
                $pdf->Cell(20, 10, utf8_decode('Nº'), 0, 0, 'C');

                // Número único em negrito
                $pdf->SetFont('Times', 'B', 12);
                $pdf->Cell(50, 10, utf8_decode($dados['numeroUnico'] . ' / '), 0, 0, 'C');

                // Data atual em negrito
                $pdf->SetFont('Times', 'B', 12);
                $pdf->Cell(25, 10, utf8_decode(date('d/m/Y')), 0, 0, 'C');

                // Texto fixo "/SFPC/3GAAE"
                $pdf->SetFont('Times', '', 12);
                $pdf->Cell(25, 10, utf8_decode('/SFPC/3º GAAAe'), 0, 1, 'C');

                $pdf->Ln(10); // Espaçamento após a linha

                // Obtendo os valores corretos
                $estadoId = isset($depositario['estadoIdSelecionado_depositario']) ? intval($depositario['estadoIdSelecionado_depositario']) : null;
                $estadoNome = isset($estados[$estadoId]) ? $estados[$estadoId] : 'N/A';

                // Extração correta dos valores de data e hora
                $data_hora = isset($depositario['data_hora_depositario']) ? $depositario['data_hora_depositario'] : 'N/A';
                $partes_data = explode('-', $data_hora);
                
                // Definir padrões se os valores não existirem
                $ano = isset($partes_data[0]) ? $partes_data[0] : 'N/A';
                $mes = isset($partes_data[1]) ? $partes_data[1] : 'N/A';
                $dia = isset($partes_data[2]) ? explode(' ', $partes_data[2])[0] : 'N/A';
                $hora = isset(explode(' ', $data_hora)[1]) ? explode(' ', $data_hora)[1] : 'N/A';

                // Cidade
                $cidade = isset($depositario['cidade_depositario']) ? $depositario['cidade_depositario'] : 'N/A';

        "Às " . $hora . " horas do dia " . $dia . " do mês de " . $mes . " do ano de " . $ano . ", " .

         $pdf->MultiCell(0, 10, utf8_decode(
            "Às " . $hora . " horas do dia " . $dia . " do mês de " . $mes . " do ano de " . $ano . ", " .
            "no Estado " . $estadoNome . ", na cidade de " . $cidade . ",  é designado como fiel depositário dos Produtos Controlados pelo Exército abaixo especificados, ficando responsável por sua guarda e preservação."));
        $pdf->Ln(10);

        // Cabeçalho da tabela
        $pdf->SetFont('Times', 'B', 12);
        $pdf->Cell(30, 10, utf8_decode('Produto'), 1, 0, 'C');
        $pdf->Cell(20, 10, utf8_decode('Qtd'), 1, 0, 'C');
        $pdf->Cell(20, 10, utf8_decode('Unidade'), 1, 0, 'C');
        $pdf->Cell(30, 10, utf8_decode('Tipo'), 1, 0, 'C');
        $pdf->Cell(30, 10, utf8_decode('Marca'), 1, 0, 'C');
        $pdf->Cell(50, 10, utf8_decode('Observação'), 1, 1, 'C');

        $pdf->SetFont('Times', '', 12);

        foreach ($depositario['produtos_depositario'] as $produto) {

            $pdf->Cell(30, 10, utf8_decode($produto['produto_depositario']), 1, 0, 'C');
            $pdf->Cell(20, 10, utf8_decode($produto['qtdApreensao_depositario']), 1, 0, 'C');
            $pdf->Cell(20, 10, utf8_decode($produto['unidade_depositario']), 1, 0, 'C');
            $pdf->Cell(30, 10, utf8_decode($produto['tipo_depositario']), 1, 0, 'C');
            $pdf->Cell(30, 10, utf8_decode($produto['marca_depositario']), 1, 0, 'C');
            $pdf->Cell(50, 10, utf8_decode($produto['obs_depositario']), 1, 1, 'C');
        }
    }

     // Garantindo espaço suficiente para as assinaturas
    $pdf->Ln(10); // Deixe um espaçamento extra após as imagens antes das assinaturas
    $pdf->SetFont('Times', 'B', 12);
    $pdf->Cell(0, 10, utf8_decode('Assinaturas:'), 1, 1, 'C');
    $pdf->Ln(5); // Pequeno espaçamento


    // Continue com as assinaturas
    $larguraTitulo = 60;
    $larguraAssinatura = 90;
    $alturaLinha = 10;
    $alturaAssinatura = 40;
    $alturaTexto = 8;
    $alturaTotalAssinatura = $alturaAssinatura + (count($assinaturas[0]['campos_extras']) + 1) * $alturaTexto + 10; // Altura total estimada


        $dados = [
    // Assinaturas
    'assinatura1' => $_POST['assinatura1'] ?? '',
    'assinatura2' => $_POST['assinatura2'] ?? '',
    'assinatura3' => $_POST['assinatura3'] ?? '',
    'assinatura4' => $_POST['assinatura4'] ?? '',

    // Dados do Fiscal Militar
    'nome_fiscal_militar' => trim($_POST['nome_fiscal_militar'] ?? ''),
    'fiscal_pg' => trim($_POST['fiscal_pg'] ?? ''),
    'idtmilitar' => trim($_POST['idtmilitar'] ?? ''),
    'ommilitar' => trim($_POST['ommilitar'] ?? ''),

    // Dados da Empresa
    'nome_empresa' => trim($_POST['nome_empresa'] ?? ''),
    'cpf_empresa' => trim($_POST['cpf_empresa'] ?? ''),

    // Testemunhas
    'testemunha1' => trim($_POST['testemunha1'] ?? ''),
    'itdtestemunha1' => trim($_POST['itdtestemunha1'] ?? ''),
    'testemunha2' => trim($_POST['testemunha2'] ?? ''),
    'itdtestemunha2' => trim($_POST['itdtestemunha2'] ?? '')
];


    // Dados das assinaturas
    $assinaturas = [
        [
            "titulo" => "Fiscal Militar",
            "nome" => $dados['nome_fiscal_militar'],
            "campos_extras" => [
                "P/G" => $dados['fiscal_pg'],
                "IDT" => $dados['idtmilitar'],
                "OM" => $dados['ommilitar']
            ]
        ],
        [
            "titulo" => "Proprietário ou Responsável Empresa ou Fiel Depositário",
            "nome" => $dados['nome_empresa'],
            "campos_extras" => [
                "CPF" => $dados['cpf_empresa']
            ]
        ],
        [
            "titulo" => "Testemunha 1",
            "nome" => $dados['itdtestemunha1'],
            "campos_extras" => [
                "IDT" => $dados['idt_testemunha1']
            ]
        ],
        [
            "titulo" => "Testemunha 2",
            "nome" => $dados['testemunha2'],
            "campos_extras" => [
                "IDT" => $dados['itdtestemunha2']
            ]
        ]
    ];

    // Processando assinaturas
    foreach ($assinaturas as $i => $assinatura) {
        $campoAssinatura = 'assinatura' . ($i + 1);

        if (isset($dados[$campoAssinatura]) && !empty($dados[$campoAssinatura])) {
            try {
                $assinaturaImg = base64paraAssinaturas($dados[$campoAssinatura], 'PDF/FormulariosPDF/' . $campoAssinatura . '.png');

                // **Verifica se há espaço suficiente na página antes de adicionar a assinatura**
                if ($pdf->GetY() + $alturaTotalAssinatura > $pdf->GetPageHeight() - 20) {
                    $pdf->AddPage();
                    $pdf->Ln(10); // Pequeno espaçamento no topo da nova página
                }

                // Linha do título
                $pdf->SetFont('Times', 'B', 12);
                $pdf->Cell(0, $alturaLinha, utf8_decode($assinatura['titulo']), 1, 1, 'C');

                // Linha da assinatura
                $posX = $pdf->GetX();
                $posY = $pdf->GetY();
                $pdf->Cell(0, $alturaAssinatura, '', 1, 1, 'C'); // Célula para a assinatura
                $pdf->Image($assinaturaImg, $posX + 40, $posY + 5, 60, 0);  // Ajuste fino da largura

                // Nome
                $pdf->SetFont('Times', '', 12);
                $pdf->Cell(40, $alturaTexto, utf8_decode("Nome:"), 1, 0, 'L');
                $pdf->Cell(150, $alturaTexto, utf8_decode($assinatura['nome']), 1, 1, 'L');

                // Campos extras (P/G, IDT, OM ou CPF)
                foreach ($assinatura['campos_extras'] as $campo => $valor) {
                    $pdf->Cell(40, $alturaTexto, utf8_decode($campo . ":"), 1, 0, 'L');
                    $pdf->Cell(150, $alturaTexto, utf8_decode($valor), 1, 1, 'L');
                }

                $pdf->Ln(5); // Pequeno espaçamento entre as assinaturas

            } catch (Exception $e) {
                error_log('Erro ao processar a assinatura: ' . $e->getMessage());
            }
        }
    }


    $pdf->MultiCell(0, 10, utf8_decode("Em caso de Recusa do Infrator em assinar o auto de Infração ou Infrator não encontrado. É valido as assinatura acima do Fiscal Militar e das Testemunhas."));
    $pdf->Ln(5); // Pequeno espaçamento

        

    // Gerando nome do arquivo
    $timestamp = time();
    $nomeArquivo = 'fiel_depositario_' . $dados['user_id'] . '_' . $timestamp . '.pdf';
    
    // Saída do PDF
    $pdf->Output('F', 'PDF/FormulariosPDF/' . $nomeArquivo);
    return $nomeArquivo;
}


// Verificar se 'listaDepositario' foi enviada e se é um JSON válido
$listaDepositario = isset($_POST['listaDepositario']) ? json_decode($_POST['listaDepositario'], true) : null;

if (is_array($listaDepositario) && !empty($listaDepositario)) {
    $dadosPDFDepositario = [
        'user_id' => $user_id,
        'numeroUnico' => $numeroUnico,
        'listaDepositario' => $listaDepositario,
    ];
    $nomeArquivoPDFDepositario = gerarPDFFielDepositario($dadosPDFDepositario);
}





// Configurar e enviar o e-mail
$mail = new PHPMailer\PHPMailer\PHPMailer(true);
try {
    $mail->isSMTP();
    $mail->Host = 'mail.florestasenegocios.com.br';  
    $mail->SMTPAuth = true;
    $mail->Username = 'sindi@florestasenegocios.com.br';
    $mail->Password = 'sindi123@A';
    $mail->SMTPSecure = PHPMailer\PHPMailer\PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port = 587;

     $mail->CharSet = 'UTF-8';

    $mail->setFrom('sindi@florestasenegocios.com.br', 'Software Exercito Fiscalizacao');
    $mail->addAddress($email, $razaoSocial);

    $mail->isHTML(true);
    $mail->Subject = 'Confirmação de Cadastro';

    // Corpo do e-mail em HTML com as variáveis corretas
     $respostasObservacoesHTML = '';
        for ($i = 0; $i < count($respostas); $i++) {
            $respostasObservacoesHTML .= '<strong>Resposta ' . ($i + 1) . ':</strong> ' . $respostas[$i] . '<br />';
            $respostasObservacoesHTML .= '<strong>Observação ' . ($i + 1) . ':</strong> ' . $observacoes[$i] . '<br /><br />';
        }


        $mail->Body = "
            <p>Seu cadastro foi realizado com sucesso! Seguem abaixo os detalhes:</p>
            <strong>RazaoSocial:</strong> $razaoSocial<br />
            <strong>Email:</strong> $email<br />
            <strong>Data:</strong> $data<br />
            <strong>TRCR:</strong> $trcr<br />
            <strong>Endereço:</strong> $endereco<br />
            <strong>Telefone:</strong> $telefone<br />
            <strong>Telefone Residencial:</strong> $telefoneResidencial<br />
            <strong>CNPJ:</strong> $cnpj<br />
            $respostasObservacoesHTML  
            <strong>$lista_deficiencia<br /><br />
            <strong>$observacoes_gerais<br /><br />
            <strong>$qtd_autos_infracao<br /><br />
            <strong>$qtd_termos_aprensao<br /><br />
            <strong>$qtd_termos_depositario<br /><br />
            <strong>$especificar_deficiencias_encontradas<br /><br />
            <strong>$prazo_deficiencias<br /><br />
            <p><em>Você não precisa responder a este e-mail.</em></p>
            <p><a href='https://woodexport.com.br/turmati/brian/aplicativo/FormFiscalizacao/PDF/FormulariosPDF/$nomeArquivoPDF'>Baixe seu PDF aqui</a></p>
            <p><a href='https://woodexport.com.br/turmati/brian/aplicativo/FormFiscalizacao/PDF/FormulariosPDF/$nomeArquivoPDFLista'>Baixe seu PDF de Apreensão aqui</a></p>
            <p><a href='https://woodexport.com.br/turmati/brian/aplicativo/FormFiscalizacao/PDF/FormulariosPDF/$nomeArquivoPDFListaInfracao'>Baixe seu PDF de Infração aqui</a></p>
            <p><a href='https://woodexport.com.br/turmati/brian/aplicativo/FormFiscalizacao/PDF/FormulariosPDF/$nomeArquivoPDFDepositario'>Baixe seu PDF de Fiel Depositário aqui</a></p>
        ";


        // Enviar o e-mail antes de retornar a resposta
        if ($mail->send()) {
            echo json_encode(["status" => "success", "message" => "Cadastro bem-sucedido. Confirmação enviada por e-mail."]);
        } else {
            error_log('Erro ao enviar e-mail: ' . $mail->ErrorInfo);
            echo json_encode(["status" => "error", "message" => "Cadastro bem-sucedido, mas erro ao enviar o e-mail."]);
        }
    } catch (Exception $e) {
        error_log('Erro ao enviar e-mail: ' . $mail->ErrorInfo);
        echo json_encode(["status" => "error", "message" => "Erro ao enviar o e-mail: " . $e->getMessage()]);
    }

    } catch (PDOException $e) {
        echo json_encode(["status" => "error", "message" => "Erro na conexão com o banco de dados: " . $e->getMessage()]);
    }
    
/*}catch(Exception $ex ){
    echo json_encode(["status" => "error", "message" => "Token Invalido "]);

}*/
    
?>
