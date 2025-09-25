import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Api.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';


class FormQuimicos extends StatefulWidget {

  final int user_id;
  final String session_token;
  final String idtMilitar;
  final String postoGraduacao;
  final String omMilitar;


  FormQuimicos({required this.user_id, required this.session_token, required this.idtMilitar, required this.postoGraduacao, required this.omMilitar});

  @override
  _FormQuimicosState createState() => _FormQuimicosState();
}
class _FormQuimicosState extends State<FormQuimicos> {

  // Controladores para os campos de entrada
  final TextEditingController razaoSocial = TextEditingController();
  final TextEditingController trcr = TextEditingController();
  final TextEditingController cnpj = TextEditingController();
  final TextEditingController endereco = TextEditingController();
  final TextEditingController telefone = TextEditingController();
  final TextEditingController telefoneResidencial = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController data = TextEditingController();
  List<String?> respostaEmpresa = []; // Lista para armazenar as respostas
  List<String> observacoes = []; // Lista para armazenar as observações

  //quimicos_atributos
  /*final TextEditingController nr_de_ord = TextEditingController();
  final TextEditingController codigo_pav_dep = TextEditingController();
  final TextEditingController destinacao = TextEditingController();
  final TextEditingController barricado = TextEditingController();
  final TextEditingController dotacao = TextEditingController();
  final TextEditingController edificio_habitado = TextEditingController();
  final TextEditingController ferrovia = TextEditingController();
  final TextEditingController rodovia = TextEditingController();
  final TextEditingController predio_proximo = TextEditingController();
  final TextEditingController cod_predio_proximo = TextEditingController();*/

  List<String?> respostaExecucao = [];
  List<String> observacoesExecucao = [];
  List<String> infracao = [];

  List<String?> campoNr_de_ord = [];
  List<String?> campoCodigo_pav_dep = [];
  List<String?> campoDestinacao = [];
  List<String?> campoBarricado = [];
  List<String?> campoDotacao = [];
  List<String?> campoEdificio_habitado = [];
  List<String?> campoFerrovia = [];
  List<String?> campoRodovia = [];
  List<String?> campoPredio_proximo = [];
  List<String?> campoCod_predio_proximo = [];

  List<TextEditingController> nr_de_ord = [];
  List<TextEditingController> codigo_pav_dep = [];
  List<TextEditingController> destinacao = [];
  List<TextEditingController> barricado = [];
  List<TextEditingController> dotacao = [];
  List<TextEditingController> edificio_habitado = [];
  List<TextEditingController> ferrovia = [];
  List<TextEditingController> rodovia = [];
  List<TextEditingController> predio_proximo = [];
  List<TextEditingController> cod_predio_proximo = [];


  final String a = "a.Operação com produtos químicos controlados";
  final String b = "b.Prevenção e combate a incêndio";
  final String c = "c.Higiene e segurança do trabalho";
  final String d = "d.Segurança de área";
  final String seisa ="a.Demais Documentos Verificados";
  final String seisb ="b.Auto(s) de infração e/ou termo(s) de apreensão lavrado(s)";

  //quimicos_Deficiencias
  final TextEditingController lista_deficiencia = TextEditingController();

  //quimicos_Observacoes_gerais
  final TextEditingController observacoes_gerais = TextEditingController();

  final TextEditingController qtd_autos_infracao = TextEditingController();
  final TextEditingController qtd_termos_aprensao = TextEditingController();
  final TextEditingController qtd_termos_depositario = TextEditingController();

  //quimicos_Deficiencias_Encontradas
  final TextEditingController especificar_deficiencias_encontradas = TextEditingController();
  final TextEditingController prazo_deficiencias = TextEditingController();

  //Atributos de Assinatura
  late SignatureController _assinatura1;
  late SignatureController _assinatura2;
  late SignatureController _assinatura3;
  late SignatureController _assinatura4;

  //Atributos de Assinatura Fiscal Indentidade ....
  final TextEditingController nome_fiscal_militar = TextEditingController();
  final TextEditingController fiscal_pg = TextEditingController();
  final TextEditingController idtmilitar = TextEditingController();
  final TextEditingController ommilitar = TextEditingController();
  final TextEditingController nome_empresa = TextEditingController();
  final TextEditingController cpf_empresa = TextEditingController();
  final TextEditingController testemunha1 = TextEditingController();
  final TextEditingController itdtestemunha1 = TextEditingController();
  final TextEditingController testemunha2 = TextEditingController();
  final TextEditingController itdtestemunha2 = TextEditingController();

  // Listas para armazenar os dados dos formulários múltiplos Apreesão
  List<TextEditingController> data_hora = [];
  List<TextEditingController> cidade = [];
  List<int?> estadoIdSelecionado = [];

// Listas para armazenar os dados dos produtos apreendidos Apreesão
  List<TextEditingController> produto = [];
  List<TextEditingController> qtdApreensao = [
  ]; // Alterado de quantidade para qtdApreensao Apreesão
  List<TextEditingController> unidade = [
  ]; // Para armazenar "kg", "Lt", "Mt", etc.
  List<TextEditingController> tipo = [];
  List<TextEditingController> marca = [];
  List<TextEditingController> obs = [];

  // Lista fixa de estados
  final List<Map<String, dynamic>> estados = [
    {'id': 1, 'nome': 'Acre'},
    {'id': 2, 'nome': 'Alagoas'},
    {'id': 3, 'nome': 'Amapá'},
    {'id': 4, 'nome': 'Amazonas'},
    {'id': 5, 'nome': 'Bahia'},
    {'id': 6, 'nome': 'Ceará'},
    {'id': 7, 'nome': 'Distrito Federal'},
    {'id': 8, 'nome': 'Espírito Santo'},
    {'id': 9, 'nome': 'Goiás'},
    {'id': 10, 'nome': 'Maranhão'},
    {'id': 11, 'nome': 'Mato Grosso'},
    {'id': 12, 'nome': 'Mato Grosso do Sul'},
    {'id': 13, 'nome': 'Minas Gerais'},
    {'id': 14, 'nome': 'Pará'},
    {'id': 15, 'nome': 'Paraíba'},
    {'id': 16, 'nome': 'Paraná'},
    {'id': 17, 'nome': 'Pernambuco'},
    {'id': 18, 'nome': 'Piauí'},
    {'id': 19, 'nome': 'Rio de Janeiro'},
    {'id': 20, 'nome': 'Rio Grande do Norte'},
    {'id': 21, 'nome': 'Rio Grande do Sul'},
    {'id': 22, 'nome': 'Rondônia'},
    {'id': 23, 'nome': 'Roraima'},
    {'id': 24, 'nome': 'Santa Catarina'},
    {'id': 25, 'nome': 'São Paulo'},
    {'id': 26, 'nome': 'Sergipe'},
    {'id': 27, 'nome': 'Tocantins'},
  ];

  // Lista de apreensões, cada uma contendo uma lista de produtos
  List<Map<String, dynamic>> apreensoes = [];

  // Inicializar listas corretamente
  void inicializarListas(int quantidade) {
    apreensoes.clear();

    for (int i = 0; i < quantidade; i++) {
      apreensoes.add({
        "data_hora_infracao": TextEditingController(text: getCurrentDateTimeFormatted()),
        "estadoIdSelecionado_infracao": null,
        "cidade_infracao": TextEditingController(),
        "produtos": [
          {
            "produto_infracao": TextEditingController(),
            "qtdApreensao_infracao": TextEditingController(),
            "unidade_infracao": TextEditingController(),
            "tipo_infracao": TextEditingController(),
            "marca_infracao": TextEditingController(),
            "obs_infracao": TextEditingController(),
          }
        ],
      });
    }
  }
  void adicionarProduto(int indexApreensao) {
    apreensoes[indexApreensao]["produtos"].add({
      "produto_infracao": TextEditingController(),
      "qtdApreensao_infracao": TextEditingController(),
      "unidade_infracao": TextEditingController(),
      "tipo_infracao": TextEditingController(),
      "marca_infracao": TextEditingController(),
      "obs_infracao": TextEditingController(),
    });
  }
  void removerProduto(int indexApreensao, int indexProduto) {
    if (apreensoes[indexApreensao]["produtos"].length > 1) {
      apreensoes[indexApreensao]["produtos"].removeAt(indexProduto);
    }
  }

  //Infração
  // Listas para armazenar os dados dos formulários múltiplos Infrações
  List<TextEditingController> data_hora_infracao = [];
  List<TextEditingController> cidade_infracao = [];
  List<int?> estadoIdSelecionado_infracao = [];

// Listas para armazenar os dados dos produtos apreendidos Infrações
  List<TextEditingController> produto_infracao = [];
  List<TextEditingController> qtdApreensao_infracao = [];
  List<TextEditingController> unidade_infracao = [];
  List<TextEditingController> tipo_infracao = [];
  List<TextEditingController> marca_infracao = [];
  List<TextEditingController> obs_infracao = [];

// Lista de infrações, cada uma contendo uma lista de produtos
  List<Map<String, dynamic>> infracoes = [];

// Inicializar lista de infrações
  void inicializarListasInfracao(int quantidade) {
    infracoes.clear();
    for (int i = 0; i < quantidade; i++) {
      infracoes.add({
        "data_hora_infracao": TextEditingController(text: getCurrentDateTimeFormatted()),
        "estadoIdSelecionado_infracao": null,
        "cidade_infracao": TextEditingController(),
        "produtos_infracao": [], // Inicializa como lista vazia
      });
    }
  }

// Método para adicionar um produto na infração
  void adicionarProdutoInfracao(int indexInfracao) {
    setState(() {
      // Garante que a chave "produtos_infracao" existe e é uma lista
      if (infracoes[indexInfracao]["produtos_infracao"] == null) {
        infracoes[indexInfracao]["produtos_infracao"] = [];
      }

      infracoes[indexInfracao]["produtos_infracao"].add({
        "produto": TextEditingController(),
        "qtdApreensao": TextEditingController(),
        "unidade": TextEditingController(),
        "tipo": TextEditingController(),
        "marca": TextEditingController(),
        "obs": TextEditingController(),
      });
    });
  }

// Método para remover um produto da infração
  void removerProdutoInfracao(int indexInfracao, int indexProduto) {
    setState(() {
      if (infracoes[indexInfracao]["produtos_infracao"] != null &&
          infracoes[indexInfracao]["produtos_infracao"].isNotEmpty) {
        infracoes[indexInfracao]["produtos_infracao"].removeAt(indexProduto);
      }
    });
  }



  // Lista de depositários, cada um contendo uma lista de produtos
  List<Map<String, dynamic>> depositarios = [];

// Listas para armazenar os dados dos formulários múltiplos Depositários
  List<TextEditingController> data_hora_depositario = [];
  List<TextEditingController> cidade_depositario = [];
  List<int?> estadoIdSelecionado_depositario = [];

// Listas para armazenar os dados dos produtos do Depositário
  List<TextEditingController> produto_depositario = [];
  List<TextEditingController> qtdApreensao_depositario = [];
  List<TextEditingController> unidade_depositario = [];
  List<TextEditingController> tipo_depositario = [];
  List<TextEditingController> marca_depositario = [];
  List<TextEditingController> obs_depositario = [];

// Inicializar lista de depositários
  void inicializarListasDepositario(int quantidade) {
    depositarios.clear();
    for (int i = 0; i < quantidade; i++) {
      depositarios.add({
        "data_hora_depositario": TextEditingController(text: getCurrentDateTimeFormatted()),
        "estadoIdSelecionado_depositario": null,
        "cidade_depositario": TextEditingController(),
        "produtos_depositario": [], // Inicializa como lista vazia
      });
    }
  }

// Método para adicionar um produto no depositário
  void adicionarProdutoDepositario(int indexDepositario) {
    setState(() {
      // Garante que a chave "produtos_depositario" existe e é uma lista
      if (depositarios[indexDepositario]["produtos_depositario"] == null) {
        depositarios[indexDepositario]["produtos_depositario"] = [];
      }

      depositarios[indexDepositario]["produtos_depositario"].add({
        "produto": TextEditingController(),
        "qtdApreensao_depositario": TextEditingController(),
        "unidade_depositario": TextEditingController(),
        "tipo_depositario": TextEditingController(),
        "marca_depositario": TextEditingController(),
        "obs_depositario": TextEditingController(),
      });
    });
  }

  void removerProdutoDepositario(int indexDepositario, int indexProduto) {
    setState(() {
      if (depositarios[indexDepositario]["produtos_depositario"] != null &&
          depositarios[indexDepositario]["produtos_depositario"].isNotEmpty) {
        depositarios[indexDepositario]["produtos_depositario"].removeAt(indexProduto);
      }
    });
  }




  List<File?> imagens = [];

  Future<void> _selectImage() async {
    final ImagePicker _picker = ImagePicker();

    // Seleciona uma imagem da galeria
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        imagens.add(File(image.path)); // Adiciona a imagem selecionada à lista
      });
    }
  }

  final TextEditingController idtMilitarController = TextEditingController();
  final TextEditingController omMilitarController = TextEditingController();
  final TextEditingController postoGraduacaoController = TextEditingController();

  //Funções para adicionar e remover campos
  void adicionarCampo() {
    setState(() {
      campoNr_de_ord.add(null);
      campoCodigo_pav_dep.add(null);
      campoDestinacao.add(null);
      campoBarricado.add(null);
      campoDotacao.add(null);
      campoEdificio_habitado.add(null);
      campoFerrovia.add(null);
      campoRodovia.add(null);
      campoPredio_proximo.add(null);
      campoCod_predio_proximo.add(null);

      nr_de_ord.add(TextEditingController());
      codigo_pav_dep.add(TextEditingController());
      destinacao.add(TextEditingController());
      barricado.add(TextEditingController());
      dotacao.add(TextEditingController());
      edificio_habitado.add(TextEditingController());
      ferrovia.add(TextEditingController());
      rodovia.add(TextEditingController());
      predio_proximo.add(TextEditingController());
      cod_predio_proximo.add(TextEditingController());

    });
  }
  // Remove um campo de texto pelo índice
  void removerCampo(int indice) {
    setState(() {
      campoNr_de_ord.removeAt(indice);
      campoCodigo_pav_dep.removeAt(indice);// Remove o valor da lista
      campoDestinacao.removeAt(indice);
      campoBarricado.removeAt(indice);
      campoDotacao.removeAt(indice);
      campoEdificio_habitado.removeAt(indice);
      campoFerrovia.removeAt(indice);
      campoRodovia.removeAt(indice);
      campoPredio_proximo.removeAt(indice);
      campoCod_predio_proximo.removeAt(indice);

      nr_de_ord[indice].dispose(); // Limpa o controlador
      nr_de_ord.removeAt(indice);// Remove o controlador da lista

      codigo_pav_dep [indice].dispose(); // Limpa o controlador
      codigo_pav_dep .removeAt(indice);

      destinacao [indice].dispose(); // Limpa o controlador
      destinacao .removeAt(indice);

      barricado [indice].dispose(); // Limpa o controlador
      barricado .removeAt(indice);

      dotacao [indice].dispose(); // Limpa o controlador
      dotacao .removeAt(indice);// Remove o controlador da lista

      edificio_habitado [indice].dispose(); // Limpa o controlador
      edificio_habitado .removeAt(indice);

      ferrovia [indice].dispose(); // Limpa o controlador
      ferrovia .removeAt(indice);

      rodovia [indice].dispose(); // Limpa o controlador
      rodovia .removeAt(indice);

      predio_proximo [indice].dispose(); // Limpa o controlador
      predio_proximo .removeAt(indice);// Remove o controlador da lista

      cod_predio_proximo  [indice].dispose(); // Limpa o controlador
      cod_predio_proximo  .removeAt(indice);// Remove o controlador da lista
    });
  }
  // Atualiza o valor na lista ao alterar o texto
  void atualizarCampo(int indice, String? valor) {
    campoNr_de_ord[indice] = valor;
  }
  void atualizarCampo1(int indice, String? valor) {
    campoCodigo_pav_dep[indice] = valor;
  }
  void atualizarCampo2(int indice, String? valor) {
    campoDestinacao[indice] = valor;
  }
  void atualizarCampo3(int indice, String? valor) {
    campoBarricado[indice] = valor;
  }
  void atualizarCampo4(int indice, String? valor) {
    campoDotacao[indice] = valor;
  }
  void atualizarCampo5(int indice, String? valor) {
    campoEdificio_habitado[indice] = valor;
  }
  void atualizarCampo6(int indice, String? valor) {
    campoFerrovia[indice] = valor;
  }
  void atualizarCampo7(int indice, String? valor) {
    campoRodovia[indice] = valor;
  }
  void atualizarCampo8(int indice, String? valor) {
    campoPredio_proximo[indice] = valor;
  }
  void atualizarCampo9(int indice, String? valor) {
    campoCod_predio_proximo[indice] = valor;
  }
  // Exibe os valores no console ou na tela
  /*void exibirCampos() {
    debugPrint(campoNr_De_Ord.toString()); // Imprime no console
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Valores'),
        content: Text(campoNr_De_Ord.toString() + campoCodigo_Pav_Dep.toString() +campoCodigo_Pav_Dep.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }
*/

  // Máscaras para os campos de entrada
  var telefoneMask = MaskTextInputFormatter(
      mask: '(##) #####-####', filter: { "#": RegExp(r'[0-9]')});
  var coordenadaMask = MaskTextInputFormatter(
      mask: '##.######, ##.######', filter: { "#": RegExp(r'[0-9]')});
  var dataMask = MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  var emailMask = MaskTextInputFormatter(
      mask: '', filter: {"#": RegExp(r'[a-zA-Z0-9@\.]')});
  var numeroMask = MaskTextInputFormatter(
      mask: '###########################################',
      filter: {"#": RegExp(r'[0-9]')}); // Máscara para números
  var cnpjMask = MaskTextInputFormatter(
      mask: '##.###.###/####-##', filter: {"#": RegExp(r'[0-9]')});
  var cpfMask = MaskTextInputFormatter(
      mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  var letrasMask = MaskTextInputFormatter(
      mask: '', filter: {"#": RegExp(r'[A-Za-z]')});

  // Formatação da data atual
  String getCurrentDateFormatted() {
    DateTime now = DateTime.now();
    return DateFormat('dd/MM/yyyy').format(now);
  }

  //Carrega Data e Hora
  static String getCurrentDateTimeFormatted() {
    DateTime now = DateTime.now();
    // Formatar para o formato adequado para o MySQL
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(now); // Ex: 2025-02-19 16:28:18
  }

// Método para enviar assinaturas para o servidor
  Future<String> converterAssinaturaparaBase64(
      SignatureController controller) async {
    final image = await controller.toPngBytes();
    if (image != null) {
      return 'data:image/png;base64,' + base64Encode(image);
    } else {
      return '';
    }
  }

  Future<String> converterImagemParaBase64(File imagem) async {
    if (imagem != null) {
      List<int> imageBytes = await imagem.readAsBytes();
      String base64String = base64Encode(imageBytes);

// Determina o tipo MIME com base na extensão da imagem
      String mimeType = 'image/png'; // Padrão
      if (imagem.path.endsWith('.jpg') || imagem.path.endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      } else if (imagem.path.endsWith('.gif')) {
        mimeType = 'image/gif';
      }

      return 'data:$mimeType;base64,' + base64String; // Retorna o base64 com o prefixo
    }
    return ''; // Caso a imagem seja nula
  }

  bool validarCampos(BuildContext context) {
    // Lista de campos de texto obrigatórios
    Map<TextEditingController, String> camposTexto = {
      razaoSocial: "Razão Social",
      email: "Email",
      endereco: "Endereço",
      trcr: "TRCR",
      nome_fiscal_militar: "Nome Fiscal/Militar",
      postoGraduacaoController: "Posto/Graduação",
      idtMilitarController: "IDT Militar",
      omMilitarController: "OM Militar",
      nome_empresa: "Nome da Empresa",
      cpf_empresa: "CPF da Empresa",
      data: "Data",
    };

    for (var campo in camposTexto.entries) {
      if (campo.key.text.trim().isEmpty) {
        _showDialogSemIternet(context, "Campo obrigatório",
            "Por favor, preencha o campo: ${campo.value}.");
        return false;
      }
    }

    // Validação do CNPJ
    if (!validarCNPJ(cnpj.text)) {
      _showDialogSemIternet(context, "CNPJ inválido",
          "Digite um CNPJ válido com 14 dígitos.");
      return false;
    }

    // Validação do telefone
    if (!validarTelefone(telefone.text)) {
      _showDialogSemIternet(context, "Telefone inválido",
          "Digite um telefone válido com DDD (10 ou 11 dígitos).");
      return false;
    }

    // Arrays obrigatórios
    Map<List<String?>, String> arraysObrigatorios = {
      respostaEmpresa: "Resposta da Empresa",
      observacoes: "Observações",
      respostaExecucao: "Resposta Execução",
      observacoesExecucao: "Observações Execução",
      infracao: "Infração"
    };

    for (var entry in arraysObrigatorios.entries) {
      List<String?> lista = entry.key;
      String nomeCampo = entry.value;

      if (lista.isEmpty) {
        _showDialogSemIternet(context, "Campo obrigatório",
            "O campo '$nomeCampo', Sim, Não , e Não se Aplica precisa ser preenchido.");
        return false;
      }

      for (int i = 0; i < lista.length; i++) {
        if (lista[i] == null || lista[i]!.trim().isEmpty) {
          // Aplica S/A apenas para observações e observaçõesExecucao
          if (entry.key == observacoes || entry.key == observacoesExecucao) {
            lista[i] = "S/A";
          } else {
            _showDialogSemIternet(context, "Campo obrigatório",
                "Todos os itens do campo '$nomeCampo' Observações devem ser preenchidos.");
            return false;
          }
        }
      }
    }

    // Validação de assinaturas
    Map<SignatureController, String> assinaturas = {
      _assinatura1: "Assinatura 1",
      _assinatura2: "Assinatura 2",
    };

    for (var assinatura in assinaturas.entries) {
      if (assinatura.key.isEmpty) {
        _showDialogSemIternet(context, "Assinatura obrigatória",
            "A ${assinatura.value} deve ser preenchida antes de salvar.");
        return false;
      }
    }

    // Validação condicional dos campos de infração
    if (infracao.any((item) => item != null && item.toLowerCase().contains("sim"))) {
      if (qtd_autos_infracao.text.trim().isEmpty ||
          qtd_termos_aprensao.text.trim().isEmpty ||
          qtd_termos_depositario.text.trim().isEmpty) {
        _showDialogSemIternet(context, "Campo obrigatório",
            "Como houve infração, preencha pelo menos um dos campos: Qtd. Autos de Infração, Qtd. Termos de Apreensão ou Qtd. Termos de Depositário.");
        return false;
      }
    }

    return true;
  }

  bool validarFormatoEDataValida(String data) {
    RegExp regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');

    if (!regex.hasMatch(data)) {
      return false; // Retorna falso se não estiver no formato correto
    }

    List<String> partes = data.split('/');
    int dia = int.parse(partes[0]);
    int mes = int.parse(partes[1]);
    int ano = int.parse(partes[2]);

    // Validação da data real
    if (mes < 1 || mes > 12 || dia < 1 || dia > 31) return false;

    // Valida dias máximos de cada mês
    List<int> diasPorMes = [
      31,
      _isAnoBissexto(ano) ? 29 : 28,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31
    ];

    if (dia > diasPorMes[mes - 1]) return false;

    return true;
  }

  bool _isAnoBissexto(int ano) {
    return (ano % 4 == 0 && ano % 100 != 0) || (ano % 400 == 0);
  }


  bool validarCNPJ(String cnpj) {
    // Expressão regular para validar o formato XX.XXX.XXX/XXXX-XX
    RegExp regExp = RegExp(r'^\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}$');

    // Verifica se o CNPJ corresponde ao padrão da expressão regular
    return regExp.hasMatch(cnpj);
  }

// Função para validar telefone
  bool validarTelefone(String telefone) {
    // Expressão regular para validar o formato (##) #####-####
    RegExp regExp = RegExp(r'^\(\d{2}\) \d{5}-\d{4}$');

    // Verifica se o telefone corresponde ao padrão da expressão regular
    return regExp.hasMatch(telefone);
  }

// Método para enviar os dados ao servidor
  Future<void> enviarDadosFormulario(BuildContext context) async {
    print("Enviando dados...");

    String urlApi = Api.url;
    String arquivoJson = "FormFiscalizacao/FormQuimicos.php";
    final url = Uri.parse('$urlApi$arquivoJson');

    // Converter as assinaturas para base64
    String assinatura1Base64 = await converterAssinaturaparaBase64(_assinatura1);
    String assinatura2Base64 = await converterAssinaturaparaBase64(_assinatura2);
    String assinatura3Base64 = await converterAssinaturaparaBase64(_assinatura3);
    String assinatura4Base64 = await converterAssinaturaparaBase64(_assinatura4);

    // Para cada imagem, você converte para base64
    List<String> imagensBase64 = [];
    for (var imagem in imagens) {
      if (imagem != null) {
        List<int> imageBytes = await imagem.readAsBytes();
        String base64String = base64Encode(imageBytes);



// Verifique se o base64 começa com o prefixo correto para a imagem (caso contrário, adicione-o)
        String mimeType = 'image/png'; // Aqui você pode alterar o tipo dependendo do tipo da imagem.
        base64String = 'data:$mimeType;base64,' + base64String; // Adiciona o prefixo ao Base64

        imagensBase64.add(base64String); // Adiciona a imagem convertida com o prefixo
      }
    }





    print("URL: $url"); // Imprime a URL que está sendo chamada

    print("user_id: ${widget.user_id} (${widget.user_id.runtimeType})");
    print("razaoSocial: ${razaoSocial.text} (${razaoSocial.text.runtimeType})");
    print("respostaEmpresa: ${jsonEncode(respostaEmpresa)}");
    print("observacoes: ${jsonEncode(observacoes)}");
    print("respostaExecucao: ${jsonEncode(respostaExecucao)}");
    print("observacoes Execucao: ${jsonEncode(observacoesExecucao)}");

    print("nr_de_ord: ${jsonEncode(campoNr_de_ord)}");
    print("codigo_pav_dep: ${jsonEncode(campoCodigo_pav_dep)}");
    print("destinacao: ${jsonEncode(campoDestinacao)}");
    print("barricado : ${jsonEncode(campoBarricado )}");
    print("dotacao : ${jsonEncode(campoDotacao)}");
    print("edificio_habitado : ${jsonEncode(campoEdificio_habitado)}");
    print("ferrovia : ${jsonEncode(campoFerrovia)}");
    print("rodovia : ${jsonEncode(campoRodovia)}");
    print("predio_proximo : ${jsonEncode(campoPredio_proximo)}");
    print("cod_predio_proximo : ${jsonEncode(campoCod_predio_proximo)}");

    print("Infração: $infracao");

    print({
      'assinaturas1': assinatura1Base64,
      'assinaturas2': assinatura2Base64,
      'assinaturas3': assinatura3Base64,
      'assinaturas4': assinatura4Base64,
    });

    List<Map<String, dynamic>> listaApreensao = [];

    // Verifique se a lista apreensoes não está vazia
    if (apreensoes.isEmpty) {
      print("ERRO: A lista de apreensões está vazia!");
    } else {
      for (var i = 0; i < apreensoes.length; i++) {
        var apreensao = apreensoes[i];

        // Debug: Mostrando o conteúdo de cada apreensão antes da conversão
        print("Apreensão [$i]: ${apreensao.toString()}");

        if (apreensao.containsKey("produtos") && apreensao["produtos"] is List) {
          List<Map<String, dynamic>> produtos = (apreensao["produtos"] as List)
              .map((produto) {
            return {
              "produto": produto["produto"].text,
              "qtdApreensao": produto["qtdApreensao"].text,
              "unidade": produto["unidade"].text,
              "tipo": produto["tipo"].text,
              "marca": produto["marca"].text,
              "obs": produto["obs"].text,
            };
          }).toList();

          listaApreensao.add({
            "data_hora": apreensao["data_hora"].text,
            "estadoIdSelecionado": apreensao["estadoIdSelecionado"],
            "cidade": apreensao["cidade"].text,
            "produtos": produtos,
          });
        } else {
          print("ERRO: Produtos inválidos ou ausentes na apreensão [$i]");
        }
      }
    }

    // Debug: Exibir a lista final antes do envio
    print("Lista de apreensões JSON: ${jsonEncode(listaApreensao)}");


    List<Map<String, dynamic>> listaInfracao = [];

    // Verifique se a lista de infrações não está vazia
    if (infracoes.isEmpty) {
      print("ERRO: A lista de infrações está vazia!");
    } else {
      for (var i = 0; i < infracoes.length; i++) {
        var infracao = infracoes[i]; // Pega a infração específica

        // Debug: Mostrando o conteúdo de cada infração antes da conversão
        print("Infração [$i]: ${infracao.toString()}");

        // Verifica se a infração contém produtos e se é uma lista válida
        if (infracao.containsKey("produtos_infracao") && infracao["produtos_infracao"] is List) {
          List<Map<String, dynamic>> produtos = (infracao["produtos_infracao"] as List)
              .map((produto) {
            return {
              "produto_infracao": produto["produto_infracao"].text,
              "qtdApreensao_infracao": produto["qtdApreensao_infracao"].text,
              "unidade_infracao": produto["unidade_infracao"].text,
              "tipo_infracao": produto["tipo_infracao"].text,
              "marca_infracao": produto["marca_infracao"].text,
              "obs_infracao": produto["obs_infracao"].text,
            };
          }).toList();

          // Adiciona a infração formatada na lista final
          listaInfracao.add({
            "data_hora_infracao": infracao["data_hora_infracao"].text,
            "estadoIdSelecionado_infracao": infracao["estadoIdSelecionado_infracao"],
            "cidade_infracao": infracao["cidade_infracao"].text,
            "produtos_infracao": produtos,
          });
        } else {
          print("ERRO: Produtos inválidos ou ausentes na infração [$i]");
        }
      }
    }

    // Debug: Exibir a lista final antes do envio
    print("Lista de infrações JSON: ${jsonEncode(listaInfracao)}");

    List<Map<String, dynamic>> listaDepositario = [];

// Verifique se a lista de depositários não está vazia
    if (depositarios.isEmpty) {
      print("ERRO: A lista de depositários está vazia!");
    } else {
      for (var i = 0; i < depositarios.length; i++) {
        var depositario = depositarios[i]; // Pega o depositário específico

        // Debug: Mostrando o conteúdo de cada depositário antes da conversão
        print("Depositário [$i]: ${depositario.toString()}");

        // Verifica se o depositário contém produtos e se é uma lista válida
        if (depositario.containsKey("produtos_depositario") && depositario["produtos_depositario"] is List) {
          List<Map<String, dynamic>> produtos = (depositario["produtos_depositario"] as List)
              .map((produto) {
            return {
              "produto_depositario": produto["produto_depositario"].text,
              "qtdApreensao_depositario": produto["qtdApreensao_depositario"].text,
              "unidade_depositario": produto["unidade_depositario"].text,
              "tipo_depositario": produto["tipo_depositario"].text,
              "marca_depositario": produto["marca_depositario"].text,
              "obs_depositario": produto["obs_depositario"].text,
            };
          }).toList();

          // Adiciona o depositário formatado na lista final
          listaDepositario.add({
            "data_hora_depositario": depositario["data_hora_depositario"].text,
            "estadoIdSelecionado_depositario": depositario["estadoIdSelecionado_depositario"],
            "cidade_depositario": depositario["cidade_depositario"].text,
            "produtos_depositario": produtos,
          });
        } else {
          print("ERRO: Produtos inválidos ou ausentes no depositário [$i]");
        }
      }
    }

// Debug: Exibir a lista final antes do envio
    print("Lista de depositários JSON: ${jsonEncode(listaDepositario)}");
// Debug: Exibir a lista final antes do envio
    print("Lista de depositários JSON: ${jsonEncode(listaDepositario)}");

    List<ConnectivityResult> connectivityResults = await Connectivity().checkConnectivity();

    if (connectivityResults.contains(ConnectivityResult.none)) {
      print("Sem conexão. Salvando localmente...");
      await salvarDadosLocalmente();
      _showDialog(context, "Dados Salvos Localmente", "Os dados foram salvos localmente.");
      return; // IMPEDINDO O ENVIO SEM INTERNET
    }

    final response = await http.post(
      url,
      body: {
        'user_id': widget.user_id.toString(),
        'session_token': widget.session_token, // Envia o session_token
        'razaoSocial': razaoSocial.text,
        'email': email.text,
        'trcr': trcr.text,
        'endereco': endereco.text,
        'telefone': telefone.text,
        'telefoneResidencial': telefoneResidencial.text,
        'cnpj': cnpj.text,
        'respostaEmpresa': jsonEncode(respostaEmpresa), // Envia como JSON
        'observacoes': jsonEncode(observacoes), // Envia como JSON
        'data': data.text,

        'nr_de_ord': jsonEncode(campoNr_de_ord),
        'codigo_pav_dep': jsonEncode(campoCodigo_pav_dep),
        'destinacao': jsonEncode(campoDestinacao),
        'barricado': jsonEncode(campoBarricado),
        'dotacao': jsonEncode(campoDotacao),
        'edificio_habitado': jsonEncode(campoEdificio_habitado),
        'ferrovia': jsonEncode(campoFerrovia),
        'rodovia': jsonEncode(campoRodovia),
        'predio_proximo': jsonEncode(campoPredio_proximo),
        'cod_predio_proximo': jsonEncode(campoCod_predio_proximo),

        'respostaExecucao': jsonEncode(respostaExecucao),
        'observacoesExecucao': jsonEncode(observacoesExecucao),
        'lista_deficiencia': lista_deficiencia.text,
        'observacoes_gerais': observacoes_gerais.text,
        'infracao': jsonEncode(infracao), // Usa a conversão correta
        'qtd_autos_infracao': qtd_autos_infracao.text.isNotEmpty ? qtd_autos_infracao.text.toString() : '0',
        'qtd_termos_aprensao': qtd_termos_aprensao.text.isNotEmpty ? qtd_termos_aprensao.text.toString() : '0',
        'qtd_termos_depositario': qtd_termos_depositario.text.isNotEmpty ? qtd_termos_depositario.text.toString() : '0',
        'especificar_deficiencias_encontradas': especificar_deficiencias_encontradas.text,
        'prazo_deficiencias': prazo_deficiencias.text,

        'nome_fiscal_militar': nome_fiscal_militar.text,
        'fiscal_pg': postoGraduacaoController.text,
        'idtmilitar': idtMilitarController.text,
        'ommilitar': omMilitarController.text,
        'nome_empresa': nome_empresa.text,
        'cpf_empresa': cpf_empresa.text,
        'testemunha1': testemunha1.text,
        'itdtestemunha1': itdtestemunha1.text,
        'testemunha2': testemunha2.text,
        'itdtestemunha2': itdtestemunha2.text,

        'assinatura1': assinatura1Base64,
        'assinatura2': assinatura2Base64,
        'assinatura3': assinatura3Base64,
        'assinatura4': assinatura4Base64,
        'imagens':jsonEncode(imagensBase64),

        //Termos Apreensão.
        'listaApreensao': jsonEncode(listaApreensao),
        //Termo Infracao
        'listaInfracao': jsonEncode(listaInfracao),
        // Termo Fiel Depositário
        'listaDepositario': jsonEncode(listaDepositario),

      },
    );

    print("Status da resposta: ${response.statusCode}"); // Imprime o status da resposta

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        _showDialog(context, "Sucesso", "Cadastro bem-sucedido.");
        limparCampos();
      } else {
        _showDialog(context, "Erro", responseData['message'].toString());
        print("Erro ao enviar dados: ${responseData['message']}");
      }
    } else {
      _showDialog(context, "Erro de Conexão", "Erro de Conexão com o Servidor");
    }

  }

  // Método para salvar os dados localmente
  Future<void> salvarDadosLocalmente() async {

    if (!validarCampos(context)) {
      return; // Se a validação falhar, interrompe o processo
    }

    List<ConnectivityResult> connectivityResults = await Connectivity()
        .checkConnectivity();
    bool semConexao = connectivityResults.contains(ConnectivityResult.none);

    if (semConexao) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> dadosLocaisQuimicos = prefs.getStringList(
          'dadosLocaisQuimicos') ?? [];
      // Verifique se as assinaturas são válidas
      if (_assinatura1 == null || _assinatura2 == null ||
          _assinatura3 == null || _assinatura4 == null) {
        print("Uma ou mais assinaturas estão nulas.");
        return; // Retorna se alguma assinatura for nula
      }


      // Verifique se as assinaturas são válidas
      if (_assinatura1 == null || _assinatura2 == null ||
          _assinatura3 == null || _assinatura4 == null) {
        print("Uma ou mais assinaturas estão nulas.");
        return; // Retorna se alguma assinatura for nula
      }

      // Converte assinaturas para base64
      String assinatura1Base64 = await converterAssinaturaparaBase64(
          _assinatura1);
      String assinatura2Base64 = await converterAssinaturaparaBase64(
          _assinatura2);
      String assinatura3Base64 = await converterAssinaturaparaBase64(
          _assinatura3);
      String assinatura4Base64 = await converterAssinaturaparaBase64(
          _assinatura4);

      List<String> imagensBase64 = await Future.wait(
        imagens.map((imagem) => converterImagemParaBase64(imagem!)),
      );
      imagensBase64.removeWhere((imagem) => imagem.isEmpty);

      List<Map<String, dynamic>> listaApreensao = [];

      // Verifique se a lista apreensoes não está vazia
      if (apreensoes.isEmpty) {
        print("ERRO: A lista de apreensões está vazia!");
      } else {
        for (var i = 0; i < apreensoes.length; i++) {
          var apreensao = apreensoes[i];

          // Debug: Mostrando o conteúdo de cada apreensão antes da conversão
          print("Apreensão [$i]: ${apreensao.toString()}");

          if (apreensao.containsKey("produtos") &&
              apreensao["produtos"] is List) {
            List<
                Map<String, dynamic>> produtos = (apreensao["produtos"] as List)
                .map((produto) {
              return {
                "produto": produto["produto"].text,
                "qtdApreensao": produto["qtdApreensao"].text,
                "unidade": produto["unidade"].text,
                "tipo": produto["tipo"].text,
                "marca": produto["marca"].text,
                "obs": produto["obs"].text,
              };
            }).toList();

            listaApreensao.add({
              "data_hora": apreensao["data_hora"].text,
              "estadoIdSelecionado": apreensao["estadoIdSelecionado"],
              "cidade": apreensao["cidade"].text,
              "produtos": produtos,
            });
          } else {
            print("ERRO: Produtos inválidos ou ausentes na apreensão [$i]");
          }
        }
      }

      // Debug: Exibir a lista final antes do envio
      print("Lista de apreensões JSON: ${jsonEncode(listaApreensao)}");


      List<Map<String, dynamic>> listaInfracao = [];

      // Verifique se a lista de infrações não está vazia
      if (infracoes.isEmpty) {
        print("ERRO: A lista de infrações está vazia!");
      } else {
        for (var i = 0; i < infracoes.length; i++) {
          var infracao = infracoes[i]; // Pega a infração específica

          // Debug: Mostrando o conteúdo de cada infração antes da conversão
          print("Infração [$i]: ${infracao.toString()}");

          // Verifica se a infração contém produtos e se é uma lista válida
          if (infracao.containsKey("produtos_infracao") &&
              infracao["produtos_infracao"] is List) {
            List<Map<String,
                dynamic>> produtos = (infracao["produtos_infracao"] as List)
                .map((produto) {
              return {
                "produto_infracao": produto["produto_infracao"].text,
                "qtdApreensao_infracao": produto["qtdApreensao_infracao"].text,
                "unidade_infracao": produto["unidade_infracao"].text,
                "tipo_infracao": produto["tipo_infracao"].text,
                "marca_infracao": produto["marca_infracao"].text,
                "obs_infracao": produto["obs_infracao"].text,
              };
            }).toList();

            // Adiciona a infração formatada na lista final
            listaInfracao.add({
              "data_hora_infracao": infracao["data_hora_infracao"].text,
              "estadoIdSelecionado_infracao": infracao["estadoIdSelecionado_infracao"],
              "cidade_infracao": infracao["cidade_infracao"].text,
              "produtos_infracao": produtos,
            });
          } else {
            print("ERRO: Produtos inválidos ou ausentes na infração [$i]");
          }
        }
      }

      // Debug: Exibir a lista final antes do envio
      print("Lista de infrações JSON: ${jsonEncode(listaInfracao)}");

      List<Map<String, dynamic>> listaDepositario = [];

// Verifique se a lista de depositários não está vazia
      if (depositarios.isEmpty) {
        print("ERRO: A lista de depositários está vazia!");
      } else {
        for (var i = 0; i < depositarios.length; i++) {
          var depositario = depositarios[i]; // Pega o depositário específico

          // Debug: Mostrando o conteúdo de cada depositário antes da conversão
          print("Depositário [$i]: ${depositario.toString()}");

          // Verifica se o depositário contém produtos e se é uma lista válida
          if (depositario.containsKey("produtos_depositario") &&
              depositario["produtos_depositario"] is List) {
            List<Map<String,
                dynamic>> produtos = (depositario["produtos_depositario"] as List)
                .map((produto) {
              return {
                "produto_depositario": produto["produto_depositario"].text,
                "qtdApreensao_depositario": produto["qtdApreensao_depositario"]
                    .text,
                "unidade_depositario": produto["unidade_depositario"].text,
                "tipo_depositario": produto["tipo_depositario"].text,
                "marca_depositario": produto["marca_depositario"].text,
                "obs_depositario": produto["obs_depositario"].text,
              };
            }).toList();

            // Adiciona o depositário formatado na lista final
            listaDepositario.add({
              "data_hora_depositario": depositario["data_hora_depositario"]
                  .text,
              "estadoIdSelecionado_depositario": depositario["estadoIdSelecionado_depositario"],
              "cidade_depositario": depositario["cidade_depositario"].text,
              "produtos_depositario": produtos,
            });
          } else {
            print("ERRO: Produtos inválidos ou ausentes no depositário [$i]");
          }
        }
      }

// Debug: Exibir a lista final antes do envio
      print("Lista de depositários JSON: ${jsonEncode(listaDepositario)}");

      // Cria um mapa com os dados do formulário
      Map<String, dynamic> dados = {
        'user_id': widget.user_id.toString(),
        'session_token': widget.session_token, // Envia o session_token
        // Envia o session_token
        'razaoSocial': razaoSocial.text,
        'email': email.text,
        'trcr': trcr.text,
        'endereco': endereco.text,
        'telefone': telefone.text,
        'telefoneResidencial': telefoneResidencial.text,
        'cnpj': cnpj.text,
        'respostaEmpresa': jsonEncode(respostaEmpresa),
        'observacoes': jsonEncode(observacoes),
        'data': data.text.isNotEmpty ? data.text : DateTime.now().toString(),

        'campoNr_de_ord': jsonEncode(campoNr_de_ord),
        'campoCodigo_pav_dep': jsonEncode(campoCodigo_pav_dep),
        'campoDestinacao': jsonEncode(campoDestinacao),
        'campoBarricado': jsonEncode(campoBarricado),
        'campoDotacao': jsonEncode(campoDotacao),
        'campoEdificio_habitado': jsonEncode(campoEdificio_habitado),
        'campoFerrovia': jsonEncode(campoFerrovia),
        'campoRodovia': jsonEncode(campoRodovia),
        'campoPredio_proximo': jsonEncode(campoPredio_proximo),
        'campoCod_predio_proximo': jsonEncode(campoCod_predio_proximo),

        'respostaExecucao': jsonEncode(respostaExecucao),
        'observacoesExecucao': jsonEncode(observacoesExecucao),
        'lista_deficiencia': lista_deficiencia.text,
        'observacoes_gerais': observacoes_gerais.text,
        'infracao': jsonEncode(infracao),
        'qtd_autos_infracao': qtd_autos_infracao.text.isNotEmpty
            ? qtd_autos_infracao.text
            : '0',
        'qtd_termos_aprensao': qtd_termos_aprensao.text.isNotEmpty ? int
            .tryParse(qtd_termos_aprensao.text)?.toString() ?? '0' : '0',
        'qtd_termos_depositario': qtd_termos_depositario.text.isNotEmpty
            ? qtd_termos_depositario.text
            : '0',
        'especificar_deficiencias_encontradas': especificar_deficiencias_encontradas
            .text,
        'prazo_deficiencias': prazo_deficiencias.text,
        'nome_fiscal_militar': nome_fiscal_militar.text,
        'postoGraduacaoController': postoGraduacaoController.text,
        'idtMilitarController': idtMilitarController.text,
        'omMilitarController': omMilitarController.text,
        'nome_empresa': nome_empresa.text,
        'cpf_empresa': cpf_empresa.text,
        'testemunha1': testemunha1.text,
        'itdtestemunha1': itdtestemunha1.text,
        'testemunha2': testemunha2.text,
        'itdtestemunha2': itdtestemunha2.text,
        'assinatura1Base64': assinatura1Base64,
        'assinatura2Base64': assinatura2Base64,
        'assinatura3Base64': assinatura3Base64,
        'assinatura4Base64': assinatura4Base64,
        'imagens': imagensBase64,

        'listaApreensao': listaApreensao,
        // Adicionando a lista de apreensão
        'listaInfracao': listaInfracao,
        // Adicionando a lista de infração
        'listaDepositario': listaDepositario,
        // Adicionando a lista de fiel depositário
      };

      // Adiciona dados convertidos à lista de dados locais
      dadosLocaisQuimicos.add(jsonEncode(dados));
      await prefs.setStringList('dadosLocaisQuimicos', dadosLocaisQuimicos);
      setState(() {}); // Atualiza o estado imediatamente após salvar
    }
  }

  void limparCampos() {
    setState(() {
// Limpar os campos de texto
      razaoSocial.clear();
      email.clear();
      trcr.clear();
      endereco.clear();
      telefone.clear();
      telefoneResidencial.clear();
      cnpj.clear();
      /*obra.clear();
      referencia.clear();
// coordenada.clear();
// data.clear();
      nr_validade.clear();
      empresa_executante.clear();
      nome_responsavel.clear();
      carteira_blaster.clear();
      cpf_responsavel.clear();
      nome_designado.clear();
      cargo_empresa.clear();
      cpf_designado.clear();*/
      lista_deficiencia.clear();
      observacoes_gerais.clear();
      qtd_autos_infracao.clear();
      qtd_termos_aprensao.clear();
      qtd_termos_depositario.clear();
      especificar_deficiencias_encontradas.clear();
      prazo_deficiencias.clear();
      nome_fiscal_militar.clear();
      fiscal_pg.clear();
      idtmilitar.clear();
      ommilitar.clear();
      nome_empresa.clear();
      cpf_empresa.clear();
      testemunha1.clear();
      itdtestemunha1.clear();
      testemunha2.clear();
      itdtestemunha2.clear();

// Limpar as assinaturas
      _assinatura1.clear();
      _assinatura2.clear();
      _assinatura3.clear();
      _assinatura4.clear();

// Limpar imagens
      imagens.clear();

// widget.user_id = null; // Limpar o session_token
// widget.session_token = null; // Limpar o session_token

// Você pode também resetar as variáveis de texto para os valores padrão
      respostaEmpresa = [];
      observacoes = [];
      respostaExecucao = [];
      observacoesExecucao = [];
      infracao = [];
// Aqui você pode definir valores vazios ou null conforme necessário para essas variáveis
    });
  }

  // Método para enviar os dados salvos localmente
  Future<void> enviarDadosSalvosLocalmente(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> dadosLocaisQuimicos = prefs.getStringList('dadosLocaisQuimicos') ?? [];

    if (dadosLocaisQuimicos.isEmpty) {
      print("Nenhum dado local encontrado para enviar.");
      return; // Se não houver dados, não faça nada
    }


    List<Map<String, dynamic>> listaApreensao = [];

    // Verifique se a lista apreensoes não está vazia
    if (apreensoes.isEmpty) {
      print("ERRO: A lista de apreensões está vazia!");
    } else {
      for (var i = 0; i < apreensoes.length; i++) {
        var apreensao = apreensoes[i];

        // Debug: Mostrando o conteúdo de cada apreensão antes da conversão
        print("Apreensão [$i]: ${apreensao.toString()}");

        if (apreensao.containsKey("produtos") && apreensao["produtos"] is List) {
          List<Map<String, dynamic>> produtos = (apreensao["produtos"] as List)
              .map((produto) {
            return {
              "produto": produto["produto"].text,
              "qtdApreensao": produto["qtdApreensao"].text,
              "unidade": produto["unidade"].text,
              "tipo": produto["tipo"].text,
              "marca": produto["marca"].text,
              "obs": produto["obs"].text,
            };
          }).toList();

          listaApreensao.add({
            "data_hora": apreensao["data_hora"].text,
            "estadoIdSelecionado": apreensao["estadoIdSelecionado"],
            "cidade": apreensao["cidade"].text,
            "produtos": produtos,
          });
        } else {
          print("ERRO: Produtos inválidos ou ausentes na apreensão [$i]");
        }
      }
    }

    // Debug: Exibir a lista final antes do envio
    print("Lista de apreensões JSON: ${jsonEncode(listaApreensao)}");


    List<Map<String, dynamic>> listaInfracao = [];

    // Verifique se a lista de infrações não está vazia
    if (infracoes.isEmpty) {
      print("ERRO: A lista de infrações está vazia!");
    } else {
      for (var i = 0; i < infracoes.length; i++) {
        var infracao = infracoes[i]; // Pega a infração específica

        // Debug: Mostrando o conteúdo de cada infração antes da conversão
        print("Infração [$i]: ${infracao.toString()}");

        // Verifica se a infração contém produtos e se é uma lista válida
        if (infracao.containsKey("produtos_infracao") && infracao["produtos_infracao"] is List) {
          List<Map<String, dynamic>> produtos = (infracao["produtos_infracao"] as List)
              .map((produto) {
            return {
              "produto_infracao": produto["produto_infracao"].text,
              "qtdApreensao_infracao": produto["qtdApreensao_infracao"].text,
              "unidade_infracao": produto["unidade_infracao"].text,
              "tipo_infracao": produto["tipo_infracao"].text,
              "marca_infracao": produto["marca_infracao"].text,
              "obs_infracao": produto["obs_infracao"].text,
            };
          }).toList();

          // Adiciona a infração formatada na lista final
          listaInfracao.add({
            "data_hora_infracao": infracao["data_hora_infracao"].text,
            "estadoIdSelecionado_infracao": infracao["estadoIdSelecionado_infracao"],
            "cidade_infracao": infracao["cidade_infracao"].text,
            "produtos_infracao": produtos,
          });
        } else {
          print("ERRO: Produtos inválidos ou ausentes na infração [$i]");
        }
      }
    }

    // Debug: Exibir a lista final antes do envio
    print("Lista de infrações JSON: ${jsonEncode(listaInfracao)}");

    List<Map<String, dynamic>> listaDepositario = [];

// Verifique se a lista de depositários não está vazia
    if (depositarios.isEmpty) {
      print("ERRO: A lista de depositários está vazia!");
    } else {
      for (var i = 0; i < depositarios.length; i++) {
        var depositario = depositarios[i]; // Pega o depositário específico

        // Debug: Mostrando o conteúdo de cada depositário antes da conversão
        print("Depositário [$i]: ${depositario.toString()}");

        // Verifica se o depositário contém produtos e se é uma lista válida
        if (depositario.containsKey("produtos_depositario") && depositario["produtos_depositario"] is List) {
          List<Map<String, dynamic>> produtos = (depositario["produtos_depositario"] as List)
              .map((produto) {
            return {
              "produto_depositario": produto["produto_depositario"].text,
              "qtdApreensao_depositario": produto["qtdApreensao_depositario"].text,
              "unidade_depositario": produto["unidade_depositario"].text,
              "tipo_depositario": produto["tipo_depositario"].text,
              "marca_depositario": produto["marca_depositario"].text,
              "obs_depositario": produto["obs_depositario"].text,
            };
          }).toList();

          // Adiciona o depositário formatado na lista final
          listaDepositario.add({
            "data_hora_depositario": depositario["data_hora_depositario"].text,
            "estadoIdSelecionado_depositario": depositario["estadoIdSelecionado_depositario"],
            "cidade_depositario": depositario["cidade_depositario"].text,
            "produtos_depositario": produtos,
          });
        } else {
          print("ERRO: Produtos inválidos ou ausentes no depositário [$i]");
        }
      }
    }

// Debug: Exibir a lista final antes do envio
    print("Lista de depositários JSON: ${jsonEncode(listaDepositario)}");


    // Itera sobre cada registro salvo
    for (String dadosJson in dadosLocaisQuimicos) {
      try {
        // Decodificando cada registro salvo
        Map<String, dynamic> dados = jsonDecode(dadosJson);
        print("Enviando dados: $dados");

        // Decodificar os arrays armazenados como JSON
        List<String> respostaEmpresaLocal = List<String>.from(jsonDecode(dados['respostaEmpresa']));
        List<String> observacoesLocal = List<String>.from(jsonDecode(dados['observacoes']));
        List<String> respostaExecucaoLocal = List<String>.from(jsonDecode(dados['respostaExecucao']));
        List<String> observacoesExecucaoLocal = List<String>.from(jsonDecode(dados['observacoesExecucao']));



        // Enviando ao servidor
        await enviarDadosParaServidor(
          dados['razaoSocial'],
          dados['email'],
          dados['data'],
          dados['trcr'],
          dados['endereco'],
          dados['telefone'],
          dados['telefoneResidencial'],
          dados['cnpj'],
          jsonEncode(respostaEmpresaLocal),
          jsonEncode(observacoesLocal),

          dados['campoNr_De_Ord'],
          dados['campoCodigo_Pav_Dep'],
          dados['destinacao'],
          dados['barricado'],
          dados['dotacao'],
          dados['edificio_habitado'],
          dados['ferrovia'],
          dados['rodovia'],
          dados['predio_proximo'],
          dados['cod_predio_proximo'],

          jsonEncode(respostaExecucaoLocal),
          jsonEncode(observacoesExecucaoLocal),
          dados['lista_deficiencia'],
          dados['observacoes_gerais'],
          dados['infracao'],

          dados['qtd_autos_infracao'], // Novo atributo
          dados['qtd_termos_aprensao'], // Novo atributo
          dados['qtd_termos_depositario'], // Novo atributo
          dados['especificar_deficiencias_encontradas'], // Novo atributo
          dados['prazo_deficiencias'], // Novo atributo
          dados['nome_fiscal_militar'], // Novo atributo
          dados['postoGraduacaoController'], // Novo atributo
          dados['idtMilitarController'], // Novo atributo
          dados['omMilitarController'], // Novo atributo
          dados['nome_empresa'], // Novo atributo
          dados['cpf_empresa'], // Novo atributo
          dados['testemunha1'], // Novo atributo
          dados['itdtestemunha1'], // Novo atributo
          dados['testemunha2'], // Novo atributo
          dados['itdtestemunha2'], // Novo atributo

          dados ['assinatura1Base64'],
          dados ['assinatura2Base64'],
          dados ['assinatura3Base64'],
          dados ['assinatura4Base64'],

          dados ['imagensBase64'],

          dados ['listaApreensaoJson'], // Dados de apreensão
          dados['istaInfracaoJson'], // Dados de infração
          dados ['listaDepositarioJson'], // Dados de fiel depositário


        );

        print("Dados enviados com sucesso: $dados");
      } catch (e) {
        print("Erro ao enviar dados: $e");
        // Opcional: você pode armazenar novamente os dados em uma lista de falhas para reenvio posterior
      }
    }

    // Limpar dados locais após o envio bem-sucedido de todos os registros
   // await limparDadosLocais();
  }


  Future<void> enviarDadosParaServidor(
      String razaoSocial,
      String email,
      String data,
      String trcr,
      String endereco,
      String telefone,
      String telefoneResidencial,

      String cnpj,
      String? respostaEmpresa,
      String observacoes,

      String? campoNr_de_ord,
      String? campoCodigo_pav_dep,
      String? campoDestinacao,
      String? campoBarricado,
      String? campoDotacao,
      String? campoEdificio_habitado,
      String? campoFerrovia,
      String? campoRodovia,
      String? campoPredio_proximo,
      String? campoCod_predio_proximo,

      String? respostaExecucao,
      String observacoesExecucao,
      String lista_deficiencia,
      String observacoes_gerais,
      String? infracao,

      String qtd_autos_infracao, // Novo parâmetro
      String qtd_termos_aprensao, // Novo parâmetro
      String qtd_termos_depositario, // Novo parâmetro
      String especificar_deficiencias_encontradas, // Novo parâmetro
      String prazo_deficiencias, // Novo parâmetro
      String nome_fiscal_militar, // Novo parâmetro
      String postoGraduacaoController, // Novo parâmetro
      String idtMilitarController, // Novo parâmetro
      String omMilitarController, // Novo parâmetro
      String nome_empresa, // Novo parâmetro
      String cpf_empresa, // Novo parâmetro
      String testemunha1, // Novo parâmetro
      String itdtestemunha1, // Novo parâmetro
      String testemunha2, // Novo parâmetro
      String itdtestemunha2, // Novo parâmetro


      String assinatura1Base64,
      String assinatura2Base64,
      String assinatura3Base64,
      String assinatura4Base64,
      List<String> imagensBase64,

      String listaApreensaoJson,
      String listaInfracaoJson,
      String listaDepositarioJson,

      ) async {
    String urlApi = Api.url;
    String arquivoJson = "FormFiscalizacao/FormQuimicos.php";

    final url = Uri.parse('$urlApi/$arquivoJson');
    print("Dados enviados: APRENNSAOOO 2222 : $qtd_termos_aprensao");

    for (int i = 0; i < imagensBase64.length; i++) {
      print("Imagem $i: ${imagensBase64[i].substring(0, 100)}...");
    }

    final response = await http.post(
      url,
      body: {
        'user_id': widget.user_id.toString(),
        'session_token': widget.session_token, // Envia o session_token
        'razaoSocial': razaoSocial,
        'email': email,
        'trcr': trcr,
        'endereco': endereco,
        'telefone': telefone,
        'telefoneResidencial': telefoneResidencial,
        'cnpj': cnpj,
        'respostaEmpresa': respostaEmpresa ?? '',
        'observacoes': observacoes,
        'data': data,

        'nr_de_ord': campoNr_de_ord,
        'codigo_pav_dep': campoCodigo_pav_dep,
        'destinacao': campoDestinacao,
        'barricado': campoBarricado,
        'dotacao': campoDotacao,
        'edificio_habitado': campoEdificio_habitado,
        'ferrovia': campoFerrovia,
        'rodovia': campoRodovia,
        'predio_proximo': campoPredio_proximo,
        'cod_predio_proximo': campoCod_predio_proximo,

        'respostaExecucao': respostaExecucao ?? '',
        'observacoesExecucao': observacoesExecucao,
        'lista_deficiencia': lista_deficiencia,
        'observacoes_gerais': observacoes_gerais,
        'infracao': infracao ?? '',

        'qtd_autos_infracao': qtd_autos_infracao, // Novo parâmetro
        'qtd_termos_aprensao': qtd_termos_aprensao, // Novo parâmetro
        'qtd_termos_depositario': qtd_termos_depositario, // Novo parâmetro
        'especificar_deficiencias_encontradas': especificar_deficiencias_encontradas, // Novo parâmetro
        'prazo_deficiencias': prazo_deficiencias, // Novo parâmetro
        'nome_fiscal_militar': nome_fiscal_militar, // Novo parâmetro
        'fiscal_pg': postoGraduacaoController, // Novo parâmetro
        'idtmilitar': idtMilitarController,
        'ommilitar': omMilitarController, // Novo parâmetro
        'nome_empresa': nome_empresa, // Novo parâmetro
        'cpf_empresa': cpf_empresa, // Novo parâmetro
        'testemunha1': testemunha1, // Novo parâmetro
        'itdtestemunha1': itdtestemunha1, // Novo parâmetro
        'testemunha2': testemunha2, // Novo parâmetro
        'itdtestemunha2': itdtestemunha2, // Novo parâmetro



        'assinatura1': assinatura1Base64,
        'assinatura2': assinatura2Base64,
        'assinatura3': assinatura3Base64,
        'assinatura4': assinatura4Base64,

        'imagens': jsonEncode(imagensBase64),

        'listaApreensao': listaApreensaoJson, // Dados de apreensão
        'listaInfracao': listaInfracaoJson, // Dados de infração
        'listaDepositario': listaDepositarioJson, // Dados de fiel depositário

      },
    );

    print("Dados enviados: APRENNSAOOO: $qtd_termos_aprensao");

    print("Status da resposta: ${response.statusCode}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print("Resposta do servidor: $responseData");

      if (responseData['status'] == 'success') {
        _showDialog(context, "Sucesso", "Cadastro bem-sucedido.");
    //    await removerRegistroLocal(jsonEncode({'razaoSocial': razaoSocial, 'email': email}));
      } else {
        _showDialog(context, "Erro", responseData['message']);
      }
    } else {
      _showDialog(context, "Erro de Conexão", "Erro de Conexão com o Servidor");
    }
  }

// Método para limpar os dados salvos localmente
  Future<void> limparDadosLocais() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('dadosLocaisQuimicos'); // Limpa todos os dados salvos
  }

// Método para carregar os dados salvos localmente
  Future<List<String>> carregarDadosLocais() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> dadosLocaisQuimicos = prefs.getStringList('dadosLocaisQuimicos') ?? [];

// Debug: verificar quantos dados locais existem
    print("Dados locais carregados: ${dadosLocaisQuimicos.length}");

    List<String> imagensBase64 = [];

    for (String dado in dadosLocaisQuimicos) {
      try {
// Decodificar o dado para um Map
        Map<String, dynamic> dadosMap = jsonDecode(dado);

// Verificando se 'imagensBase64' ou 'baseImagensBase64' existe e imprimindo o tipo
        if (dadosMap.containsKey('imagensBase64')) {
          imagensBase64 = List<String>.from(dadosMap['imagensBase64']);
          print("Imagens armazenadas em 'imagensBase64'. Número de imagens: ${imagensBase64.length}");
        } else if (dadosMap.containsKey('baseImagensBase64')) {
          imagensBase64 = List<String>.from(dadosMap['baseImagensBase64']);
          print("Imagens armazenadas em 'baseImagensBase64'. Número de imagens: ${imagensBase64.length}");
        } else {
          print("Nenhuma imagem encontrada nos dados locais.");
        }

// Aqui você pode adicionar mais verificações ou transformações nos dados

      } catch (e) {
        print("Erro ao decodificar dados locais: $e");
      }
    }

    return dadosLocaisQuimicos;
  }

// Método para remover registro local
  Future<void> removerRegistroLocal(String dados) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> dadosLocaisQuimicos = prefs.getStringList('dadosLocaisQuimicos') ?? [];

    // Apenas remove o registro específico que foi enviado
    dadosLocaisQuimicos.removeWhere((registro) => registro == dados);

    await prefs.setStringList('dadosLocaisQuimicos', dadosLocaisQuimicos);
  }

  @override
  void initState() {
    super.initState();
    carregarDadosLocais();
    // Adicionar um listener para verificar a conexão
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      // Verifica se o resultado inclui conexões móveis ou Wi-Fi
      if (result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi)) {
        carregarDadosLocais();
        // Enviar os dados salvos localmente quando a conexão é restaurada
        enviarDadosSalvosLocalmente(context);
      }
    });

    // Carregar os dados locais
    carregarDadosLocais();

    _assinatura1 = SignatureController(penStrokeWidth: 2, penColor: Colors.black);
    _assinatura2 = SignatureController(penStrokeWidth: 2, penColor: Colors.black);
    _assinatura3 = SignatureController(penStrokeWidth: 2, penColor: Colors.black);
    _assinatura4 = SignatureController(penStrokeWidth: 2, penColor: Colors.black);

    idtMilitarController.text = widget.idtMilitar;
    omMilitarController.text = widget.omMilitar;
    postoGraduacaoController.text = widget.postoGraduacao;


  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _assinatura1.dispose();
    _assinatura2.dispose();
    _assinatura3.dispose();
    _assinatura4.dispose();
    idtMilitarController.dispose();
    omMilitarController.dispose();
    postoGraduacaoController.dispose();

  }
  // Método para exibir diálogos
  void _showDialogSemIternet(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Método para exibir diálogos
  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Produtos Químicos (Empresa)"),
        backgroundColor: Color.fromRGBO(17, 48, 33, 1),
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4.0,
                color: Color.fromRGBO(17, 48, 33, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Termo de Fiscalização/Vistoria de Empresas que Realizam Atividades com produtos químicos",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              buildExpansionTile(),
              SizedBox(height: 20),
              buildExpansionVerificacaoEmpresaTile(),
              SizedBox(height: 20),
              buildExpansionCondicaoExecucaoTile(),
              SizedBox(height: 20),
              buildExpansionDistancias_SegurancasTile(),
              SizedBox(height: 20),
              buildIdentificacaoDeficienciaTile(),
              SizedBox(height: 20),
              buildIdentificacaoObservacoesGeraisTile(),
              SizedBox(height: 20,),
              buildIdentificacaoCorrecaoDeficienciaTile(),
              SizedBox(height: 20,),
              buildImagePicker(),
              SizedBox(height: 20),
              Text("Assinaturas"),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: buildAssinaturaForm("Fiscal Militar", _assinatura1)),
                  SizedBox(width: 10,),
                ],
              ),
              Row(
                children: [
                  Expanded(child:
                  buildFormField("Nome:", nome_fiscal_militar),
                  ),
                  SizedBox(width: 6,),
                  Expanded(child:
                  buildFormField("P/G:", postoGraduacaoController),

                  ),
                ],
              ),
              SizedBox(height: 6,),
              Row(
                children: [
                  Expanded(child:
                  buildFormField("Idt Mil:", idtMilitarController),
                  ),
                  SizedBox(width: 6,),
                  Expanded(child:
                  buildFormField("OM:", omMilitarController),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Expanded(child: buildAssinaturaForm("Responsável pela Empresa", _assinatura2)),
                  SizedBox(width: 10,),
                ],
              ),
              Row(
                children: [
                  Expanded(child:
                  buildFormField("Nome:", nome_empresa),
                  ),
                  SizedBox(width: 6,),
                  Expanded(child:
                  buildFormFieldComMascara("CPF:", cpf_empresa, cpfMask),
                  ),
                ],
              ),
              SizedBox(height: 6,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: buildAssinaturaForm("Testemunha 1", _assinatura3)),
                  SizedBox(width: 10,),
                ],
              ),
              Row(
                children: [
                  Expanded(child:
                  buildFormField("Nome:", testemunha1),
                  ),
                  SizedBox(width: 6,),
                  Expanded(child:
                  buildFormField("Idt:", itdtestemunha1),
                  ),
                ],
              ),
              SizedBox(height: 6,),
              Row(
                children: [
                  Expanded(child: buildAssinaturaForm("Testemunha 2", _assinatura4)),
                ],
              ),
              Row(
                children: [
                  Expanded(child:
                  buildFormField("Nome:", testemunha2),
                  ),
                  SizedBox(width: 6,),
                  Expanded(child:
                  buildFormField("Idt:", itdtestemunha2),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    int? qtdTermos = int.tryParse(qtd_termos_aprensao.text);
                    int? qtdTermosIfracao = int.tryParse(qtd_autos_infracao.text);
                    int? qtdTermosDepositario = int.tryParse(qtd_termos_depositario.text);

// Verifica se pelo menos um dos valores é válido e maior que zero
                    if ((qtdTermos != null && qtdTermos > 0) ||
                        (qtdTermosIfracao != null && qtdTermosIfracao > 0) ||
                        (qtdTermosDepositario != null && qtdTermosDepositario > 0)) {

                      exibirPopupTermosApreensao(context,
                          qtdTermos ?? 0,
                          qtdTermosIfracao ?? 0,
                          qtdTermosDepositario ?? 0
                      ); // Passando os valores para o popup

                    } else {
                      enviarDadosFormulario(context); // Grava diretamente no banco de dados
                    }
                  },
                  child: Text(
                    "Salvar dados",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }
  //campo para selecionar imagens
  Widget buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Selecione as Imagens",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _selectImage, // Chama a função para selecionar a imagem
          child: Text("Selecionar Imagem da Galeria"),
        ),
        SizedBox(height: 10),
        if (imagens.isNotEmpty) // Se houver imagens selecionadas, exibe-as
          Wrap(
            spacing: 8.0,
            children: imagens.map((imagem) {
              return Stack(
                children: [
                  Image.file(
                    imagem!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          imagens.remove(imagem); // Remove a imagem da lista
                        });
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
      ],
    );
  }

  //Formulário para Assinatura Digital
  Widget buildAssinaturaForm(String title, SignatureController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Signature(
          controller: controller,
          height: 100,
          width: double.infinity,
          backgroundColor: Colors.grey[200]!,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: (){
              controller.clear();
            },
                child: Text("Limpar")
            )
          ],
        )
      ],
    );
  }

  //Formulário de indentificação do fiscalizado
  Widget buildExpansionTile() {
    return FutureBuilder<List<String>>(
      future: carregarDadosLocais(),
      builder: (context, snapshot) {
        bool temDadosNaoSalvos = snapshot.hasData && snapshot.data!.isNotEmpty;
        String titulo = temDadosNaoSalvos
            ? "Identificação do Fiscalizado (Registros não enviados)"
            : "Identificação do Fiscalizado";

        return Container(
          margin: EdgeInsets.only(bottom: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(243, 243, 243, 1.0),
                Color.fromRGBO(217, 217, 217, 1.0),
              ],
            ),
          ),
          child: ExpansionTile(
            title: Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            children: [
              if (temDadosNaoSalvos)
                Column(
                  children: snapshot.data!.map((dados) {
                    Map<String, dynamic> dadosMap = jsonDecode(dados);
                    return ListTile(
                      title: Text("Registro salvo localmente"),
                      subtitle: Text(
                            "Data: ${dadosMap['data'] ?? 'N/A'}\n"
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () async {
                          try {
                            List<String> imagensBase64 = [];

                            // Verifica se 'imagensBase64' existe e é uma lista
                            if (dadosMap['imagens'] != null && dadosMap['imagens'] is List) {
                              imagensBase64 = List<String>.from(dadosMap['imagens']);

                              // Adiciona nomes às imagens
                              imagensBase64 = imagensBase64
                                  .asMap()
                                  .entries
                                  .map((entry) => "Imagem_${entry.key + 1}: ${entry.value}")
                                  .toList();
                            }

                            // Debug: Exibe as imagens no console
                            print("Imagens encontradas para envio:");
                            imagensBase64.forEach((imagem) {
                              print(imagem.substring(0, 100)); // Exibe apenas os primeiros 100 caracteres
                            });

                            // Chama o método que envia os dados para o servidor
                            await enviarDadosParaServidor(
                              dadosMap['razaoSocial'] ?? '',
                              dadosMap['email'] ?? '',
                              (dadosMap['data'] ?? ''),
                              dadosMap['trcr'] ?? '',
                              dadosMap['endereco'] ?? '',
                              dadosMap['telefone'] ?? '',
                              dadosMap['telefoneResidencial'] ?? '',
                              dadosMap['cnpj'] ?? '',
                              dadosMap['respostaEmpresa'] ?? '',
                              dadosMap['observacoes'] ?? '',

                              dadosMap['campoNr_de_ord'] ?? '',
                              dadosMap['campoCodigo_pav_dep'] ?? '',
                              dadosMap['campoDestinacao'] ?? '',
                              dadosMap['campoBarricado'] ?? '',
                              dadosMap['campoDotacao'] ?? '',
                              dadosMap['campoEdificio_habitado'] ?? '',
                              dadosMap['campoFerrovia'] ?? '',
                              dadosMap['campoRodovia'] ?? '',
                              dadosMap['campoPredio_proximo'] ?? '',
                              dadosMap['campoCod_predio_proximo'] ?? '',

                              dadosMap['respostaExecucao'] ?? '',
                              dadosMap['observacoesExecucao'] ?? '',
                              dadosMap['lista_deficiencia'] ?? '',
                              dadosMap['observacoes_gerais'] ?? '',
                              dadosMap['infracao'] ?? '',
                              dadosMap['qtd_autos_infracao']?.isNotEmpty == true ? dadosMap['qtd_autos_infracao'] : '0',

                              dadosMap['qtd_termos_aprensao']?.isNotEmpty == true ? dadosMap['qtd_termos_aprensao'] : '0',
                              dadosMap['qtd_termos_depositario']?.isNotEmpty == true ? dadosMap['qtd_termos_depositario'] : '0',
                              dadosMap['especificar_deficiencias_encontradas'] ?? '',
                              dadosMap['prazo_deficiencias'] ?? '',
                              dadosMap['nome_fiscal_militar'] ?? '',
                              dadosMap['postoGraduacaoController'] ?? '',
                              dadosMap['idtMilitarController'] ?? '',
                              dadosMap['omMilitarController'] ?? '',
                              dadosMap['nome_empresa'] ?? '',
                              dadosMap['cpf_empresa'] ?? '',
                              dadosMap['testemunha1'] ?? '',
                              dadosMap['itdtestemunha1'] ?? '',
                              dadosMap['testemunha2'] ?? '',
                              dadosMap['itdtestemunha2'] ?? '',
                              dadosMap['assinatura1Base64'] ?? '',
                              dadosMap['assinatura2Base64'] ?? '',
                              dadosMap['assinatura3Base64'] ?? '',
                              dadosMap['assinatura4Base64'] ?? '',
                              imagensBase64,
                              jsonEncode(dadosMap['listaApreensao'] ?? []), // Convertendo lista de apreensão para JSON
                              jsonEncode(dadosMap['listaInfracao'] ?? []), // Convertendo lista de infração para JSON
                              jsonEncode(dadosMap['listaDepositario'] ?? []), // Convertendo lista de fiel depositário para JSON


                            );

                            // Após o envio, remove o registro local
                            print("Dados enviados com sucesso! Removendo registro local...");
                            await removerRegistroLocal(dados);  // Certifique-se de que 'dados' seja o item correto

                            // Atualiza a tela após a remoção do registro
                            setState(() {
                              // Remover apenas o item específico da lista
                              snapshot.data!.removeWhere((item) => item == dados);  // Remove o item correto
                            });
                          } catch (error, stackTrace) {
                            // Em caso de erro, exibe um SnackBar com a mensagem de erro
                            print("Erro ao enviar os dados: $error");
                            print("Detalhes: $stackTrace");

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Erro ao enviar os dados. Verifique sua conexão e tente novamente."),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),

                    );
                  }).toList(),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildIdentificacaoForm(),
                    SizedBox(height: 20),

                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildIdentificacaoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFormFieldComMascara("Razão Social:", razaoSocial, letrasMask),
        SizedBox(height: 10,),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: buildFormFieldComMascara("TR/CR:", trcr, numeroMask),
            ),
            SizedBox(width: 10,),
            Expanded(
              flex: 1,
              child: buildFormFieldComMascara("CNPJ:", cnpj, cnpjMask),
            ),
          ],
        ),
        SizedBox(height: 10,),
        buildFormFieldComMascara("Endereço:", endereco, letrasMask),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: buildFormFieldComMascara("Tel:", telefone, telefoneMask),
            ),
            SizedBox(width: 10,),
            Expanded(
              flex: 1,
              child: buildFormFieldComMascara("Tel Residencial:", telefoneResidencial, telefoneMask),
            ),

          ],
        ),
        SizedBox(height: 10,),
        Row(
          children: [
            SizedBox(height: 10,),
            Expanded(
              flex: 1,
              child: buildFormFieldComMascara("E-mail:", email, emailMask),
            ),
          ],
        ),
        SizedBox(height: 10),
        buildFormFieldComMascaraData("Data:", data, dataMask),

      ],
    );
  }

  //Formulário Verificação da empresa
  Widget buildExpansionVerificacaoEmpresaTile() {
    return FutureBuilder<List<String>>(
      future: carregarDadosLocais(),
      builder: (context, snapshot) {
        bool temDadosNaoSalvos = snapshot.hasData && snapshot.data!.isNotEmpty;
        String titulo = temDadosNaoSalvos
            ? "Verificação Empresa (Registros não enviados)"
            : "Verificação Empresa";

        return Container(
          margin: EdgeInsets.only(bottom: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(243, 243, 243, 1.0),
                Color.fromRGBO(217, 217, 217, 1.0),
              ],
            ),
          ),
          child: ExpansionTile(
            title: Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            children: [
              if (temDadosNaoSalvos)
                Column(
                  children: snapshot.data!.map((dados) {
                    Map<String, dynamic> dadosMap = jsonDecode(dados);
                    return ListTile(
                      title: Text("Registro salvo localmente"),
                      subtitle: Text(
                        "Nome: ${dadosMap['nome']}\nEmail: ${dadosMap['email']}\nNúmero: ${dadosMap['numero']}",
                      ),
                      /*
                      trailing: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () async {
                          try {
                            List<String> imagensBase64 = [];

                            // Verifica se 'imagensBase64' existe e é uma lista
                            if (dadosMap['imagens'] != null && dadosMap['imagens'] is List) {
                              imagensBase64 = List<String>.from(dadosMap['imagens']);

                              // Adiciona nomes às imagens
                              imagensBase64 = imagensBase64
                                  .asMap()
                                  .entries
                                  .map((entry) => "Imagem_${entry.key + 1}: ${entry.value}")
                                  .toList();
                            }

                            // Debug: Exibe as imagens no console
                            print("Imagens encontradas para envio:");
                            imagensBase64.forEach((imagem) {
                              print(imagem.substring(0, 100)); // Exibe apenas os primeiros 100 caracteres
                            });

                            // Chama o método que envia os dados para o servidor
                            await enviarDadosParaServidor(
                              dadosMap['razaoSocial'] ?? '',
                              dadosMap['email'] ?? '',
                              (dadosMap['data'] ?? ''),
                              dadosMap['trcr'] ?? '',
                              dadosMap['endereco'] ?? '',
                              dadosMap['telefone'] ?? '',
                              dadosMap['telefoneResidencial'] ?? '',
                              dadosMap['cnpj'] ?? '',
                              dadosMap['respostaEmpresa'] ?? '',
                              dadosMap['observacoes'] ?? '',

                              dadosMap['campoNr_de_ord'] ?? '',
                              dadosMap['campoCodigo_pav_dep'] ?? '',
                              dadosMap['campoDestinacao'] ?? '',
                              dadosMap['campoBarricado'] ?? '',
                              dadosMap['campoDotacao'] ?? '',
                              dadosMap['campoEdificio_habitado'] ?? '',
                              dadosMap['campoFerrovia'] ?? '',
                              dadosMap['campoRodovia'] ?? '',
                              dadosMap['campoPredio_proximo'] ?? '',
                              dadosMap['campoCod_predio_proximo'] ?? '',

                              dadosMap['respostaExecucao'] ?? '',
                              dadosMap['observacoesExecucao'] ?? '',
                              dadosMap['lista_deficiencia'] ?? '',
                              dadosMap['observacoes_gerais'] ?? '',
                              dadosMap['infracao'] ?? '',
                              dadosMap['qtd_autos_infracao']?.isNotEmpty == true ? dadosMap['qtd_autos_infracao'] : '0',

                              dadosMap['qtd_termos_aprensao']?.isNotEmpty == true ? dadosMap['qtd_termos_aprensao'] : '0',
                              dadosMap['qtd_termos_depositario']?.isNotEmpty == true ? dadosMap['qtd_termos_depositario'] : '0',
                              dadosMap['especificar_deficiencias_encontradas'] ?? '',
                              dadosMap['prazo_deficiencias'] ?? '',
                              dadosMap['nome_fiscal_militar'] ?? '',
                              dadosMap['postoGraduacaoController'] ?? '',
                              dadosMap['idtMilitarController'] ?? '',
                              dadosMap['omMilitarController'] ?? '',
                              dadosMap['nome_empresa'] ?? '',
                              dadosMap['cpf_empresa'] ?? '',
                              dadosMap['testemunha1'] ?? '',
                              dadosMap['itdtestemunha1'] ?? '',
                              dadosMap['testemunha2'] ?? '',
                              dadosMap['itdtestemunha2'] ?? '',
                              dadosMap['assinatura1Base64'] ?? '',
                              dadosMap['assinatura2Base64'] ?? '',
                              dadosMap['assinatura3Base64'] ?? '',
                              dadosMap['assinatura4Base64'] ?? '',
                              imagensBase64,
                              jsonEncode(dadosMap['listaApreensao'] ?? []), // Convertendo lista de apreensão para JSON
                              jsonEncode(dadosMap['listaInfracao'] ?? []), // Convertendo lista de infração para JSON
                              jsonEncode(dadosMap['listaDepositario'] ?? []), // Convertendo lista de fiel depositário para JSON


                            );

                            // Após o envio, remove o registro local
                            print("Dados enviados com sucesso! Removendo registro local...");
                            await removerRegistroLocal(dados);
                          } catch (error, stackTrace) {
                            // Em caso de erro, exibe a mensagem e a pilha de erro
                            print("Erro ao enviar os dados: $error");
                            print("Detalhes: $stackTrace");
                          }
                        },
                      ),
                      */
                    );
                  }).toList(),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildIdentificacaoEmpresaForm(),
                    SizedBox(height: 20),


                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  // Construindo o formulário
  Widget buildIdentificacaoEmpresaForm() {
    List<String> perguntas = [
      "O CR/TR encontra-se ativo?",
      "A empresa possui em seu CR/TR autorização para exercer todas as atividades com PCE que executa?",
      "A empresa possui comprovação de origem lícita de todos os PCE?",
      "Toda entrada e saída de produtos químicos controlados da empresa é amparada por Guia de Tráfego?",

    ];

    if (respostaEmpresa.length < perguntas.length) {
      respostaEmpresa = List.generate(perguntas.length, (index) => "");
    }
    if (observacoes.length < perguntas.length) {
      observacoes = List.generate(perguntas.length, (index) => "");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(perguntas.length, (index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pergunta
            Row(
              children: [
                Text("${index + 1} - ", style: TextStyle(
                  color: Color.fromRGBO(17, 48, 33, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
                Expanded(
                  child: Text(perguntas[index], style: TextStyle(
                    color: Color.fromRGBO(17, 48, 33, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Respostas de RadioListTile
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text("Sim", overflow: TextOverflow.ellipsis),
                        value: "Sim",
                        groupValue: respostaEmpresa.length > index ? respostaEmpresa[index] : null,
                        onChanged: (value) {
                          setState(() {
                            if (respostaEmpresa.length > index) {
                              respostaEmpresa[index] = value;
                            } else {
                              respostaEmpresa.add(value);
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text("Não", overflow: TextOverflow.ellipsis),
                        value: "Não",
                        groupValue: respostaEmpresa.length > index ? respostaEmpresa[index] : null,
                        onChanged: (value) {
                          setState(() {
                            if (respostaEmpresa.length > index) {
                              respostaEmpresa[index] = value;
                            } else {
                              respostaEmpresa.add(value);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                RadioListTile<String>(
                  title: Text(
                    "Não se Aplica",
                  ),
                  value: "Não se Aplica",
                  groupValue: respostaEmpresa.length > index ? respostaEmpresa[index] : null,
                  onChanged: (value) {
                    setState(() {
                      if (respostaEmpresa.length > index) {
                        respostaEmpresa[index] = value;
                      } else {
                        respostaEmpresa.add(value);
                      }
                    });
                  },
                ),

              ],
            ),

            SizedBox(height: 10),

            // Observação
            Row(
              children: [
                Text("Observação:", style: TextStyle(
                  color: Color.fromRGBO(17, 48, 33, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
              ],
            ),
            SizedBox(height: 10),

            // Campo de texto para observação
            buildFormFieldEmpresa(
              "Detalhes da Observação",
              observacoes.length > index ? observacoes[index] : '',
              index,
                  (String value) {
                if (observacoes.length > index) {
                  observacoes[index] = value;
                } else {
                  observacoes.add(value);
                }
              },
            ),
            SizedBox(height: 10),
          ],
        );
      }),
    );
  }
  // Função auxiliar para construir campos de texto
  Widget buildFormFieldEmpresa(String hint, String initialValue, int index, Function(String) onChanged) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: hint,
      ),
      onChanged: (value) {
        // Verifica se o campo foi deixado em branco ou não
        if (value.isEmpty && observacoes.length <= index) {
          // Se o campo foi deixado em branco, adicione "Não se Aplica"
          onChanged("S/A");
        } else {
          // Caso contrário, mantém o valor informado
          onChanged(value);
        }
      },
      controller: TextEditingController(text: initialValue.isEmpty ? "S/A" : initialValue),

    );
  }

  //Formulário Condição Execução
  Widget buildExpansionCondicaoExecucaoTile() {
    return FutureBuilder<List<String>>(
      future: carregarDadosLocais(),
      builder: (context, snapshot) {
        bool temDadosNaoSalvos = snapshot.hasData && snapshot.data!.isNotEmpty;
        String titulo = temDadosNaoSalvos
            ? "Verificação das Condições de Execução (Registros não enviados)"
            : "Verificação das Condições de Execução";

        return Container(
          margin: EdgeInsets.only(bottom: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(243, 243, 243, 1.0),
                Color.fromRGBO(217, 217, 217, 1.0),
              ],
            ),
          ),
          child: ExpansionTile(
            title: Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            children: [
              if (temDadosNaoSalvos)
                Column(
                  children: snapshot.data!.map((dados) {
                    Map<String, dynamic> dadosMap = jsonDecode(dados);
                    return ListTile(
                      title: Text("Registro salvo localmente"),
                      subtitle: Text(
                        "Nome: ${dadosMap['nome']}\nEmail: ${dadosMap['email']}\nNúmero: ${dadosMap['numero']}",
                      ),
                      /*
                      trailing: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () async {
                          try {
                            List<String> imagensBase64 = [];

                            // Verifica se 'imagensBase64' existe e é uma lista
                            if (dadosMap['imagens'] != null && dadosMap['imagens'] is List) {
                              imagensBase64 = List<String>.from(dadosMap['imagens']);

                              // Adiciona nomes às imagens
                              imagensBase64 = imagensBase64
                                  .asMap()
                                  .entries
                                  .map((entry) => "Imagem_${entry.key + 1}: ${entry.value}")
                                  .toList();
                            }

                            // Debug: Exibe as imagens no console
                            print("Imagens encontradas para envio:");
                            imagensBase64.forEach((imagem) {
                              print(imagem.substring(0, 100)); // Exibe apenas os primeiros 100 caracteres
                            });

                            // Chama o método que envia os dados para o servidor
                            await enviarDadosParaServidor(
                              dadosMap['razaoSocial'] ?? '',
                              dadosMap['email'] ?? '',
                              (dadosMap['data'] ?? ''),
                              dadosMap['trcr'] ?? '',
                              dadosMap['endereco'] ?? '',
                              dadosMap['telefone'] ?? '',
                              dadosMap['telefoneResidencial'] ?? '',
                              dadosMap['cnpj'] ?? '',
                              dadosMap['respostaEmpresa'] ?? '',
                              dadosMap['observacoes'] ?? '',

                              dadosMap['campoNr_de_ord'] ?? '',
                              dadosMap['campoCodigo_pav_dep'] ?? '',
                              dadosMap['campoDestinacao'] ?? '',
                              dadosMap['campoBarricado'] ?? '',
                              dadosMap['campoDotacao'] ?? '',
                              dadosMap['campoEdificio_habitado'] ?? '',
                              dadosMap['campoFerrovia'] ?? '',
                              dadosMap['campoRodovia'] ?? '',
                              dadosMap['campoPredio_proximo'] ?? '',
                              dadosMap['campoCod_predio_proximo'] ?? '',

                              dadosMap['respostaExecucao'] ?? '',
                              dadosMap['observacoesExecucao'] ?? '',
                              dadosMap['lista_deficiencia'] ?? '',
                              dadosMap['observacoes_gerais'] ?? '',
                              dadosMap['infracao'] ?? '',
                              dadosMap['qtd_autos_infracao']?.isNotEmpty == true ? dadosMap['qtd_autos_infracao'] : '0',

                              dadosMap['qtd_termos_aprensao']?.isNotEmpty == true ? dadosMap['qtd_termos_aprensao'] : '0',
                              dadosMap['qtd_termos_depositario']?.isNotEmpty == true ? dadosMap['qtd_termos_depositario'] : '0',
                              dadosMap['especificar_deficiencias_encontradas'] ?? '',
                              dadosMap['prazo_deficiencias'] ?? '',
                              dadosMap['nome_fiscal_militar'] ?? '',
                              dadosMap['postoGraduacaoController'] ?? '',
                              dadosMap['idtMilitarController'] ?? '',
                              dadosMap['omMilitarController'] ?? '',
                              dadosMap['nome_empresa'] ?? '',
                              dadosMap['cpf_empresa'] ?? '',
                              dadosMap['testemunha1'] ?? '',
                              dadosMap['itdtestemunha1'] ?? '',
                              dadosMap['testemunha2'] ?? '',
                              dadosMap['itdtestemunha2'] ?? '',
                              dadosMap['assinatura1Base64'] ?? '',
                              dadosMap['assinatura2Base64'] ?? '',
                              dadosMap['assinatura3Base64'] ?? '',
                              dadosMap['assinatura4Base64'] ?? '',
                              imagensBase64,
                              jsonEncode(dadosMap['listaApreensao'] ?? []), // Convertendo lista de apreensão para JSON
                              jsonEncode(dadosMap['listaInfracao'] ?? []), // Convertendo lista de infração para JSON
                              jsonEncode(dadosMap['listaDepositario'] ?? []), // Convertendo lista de fiel depositário para JSON


                            );

                            // Após o envio, remove o registro local
                            print("Dados enviados com sucesso! Removendo registro local...");
                            await removerRegistroLocal(dados);
                          } catch (error, stackTrace) {
                            // Em caso de erro, exibe a mensagem e a pilha de erro
                            print("Erro ao enviar os dados: $error");
                            print("Detalhes: $stackTrace");
                          }
                        },
                      ),
                      */

                    );
                  }).toList(),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20,),
                    buildIdentificacaoExecucaoForm(),



                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  // Construindo o formulário

  Widget buildIdentificacaoExecucaoForm() {
//puta1
    List<String> perguntas = [
      "${jsonEncode(a)} \n"
          "Há responsável Técnico?",
      "O fabricante possui o certificado de ART expedido pelo respectivo conselho regional?",
      "As instalações são adequadas?",
      "Há instruções de trabalho escritas?",
      "Os funcionários são treinados para trabalhar com produtos controlados, perigosos ou tóxicos existentes na empresa?",
      "Há um sistema de neutralização de gases desprendidos?",



      "${jsonEncode(b)} \n"
          "Há extintores adequados em todas as áreas (administrativa, de fabricação e depósitos)",
      "Há hidrantes e mangueiras dispostas estrategicamente nas áreas de fabricação e depóstios?",
      "Há equipe de combate a incêndio  constituída e devidamente treinada?",
      "A rede hidráulica de segurança é separada da rede industrial?",
      "\n"
          "${jsonEncode(c)} \n"
          "Há normas de segurança escritas?",
      "Há uma CIPA - Comissão interan de Prevençaõ de Acidentes constituída e que se reúne periodicanebte para tratar da prevenção de acidentes?",
      "Os funcionários usam EPI - Equipamentos de Porteção Individual (Óculos de segurança, luvas etc.)?",
      "Há chuveiros e lava-olhos colocados en pontos estratégicos dentro da área perigosa da empresa?",
      "Os funcionários são treinados quanto às medidas de higiene e primeiros socorros?",
      "Há ordem explícita (avisos, placas, instruções de trabalho etc.) proibindo o ato de fumar ou ação de produzir fogo ou centelha",
      "Há plano de emergência abranggendo rotas de fuga, combate a vazamentos líquidos, nuvem tóxica, etc?",
      "Há ordens explícitas (avisos, placas etc.) proibindo atos inseguros (fumar, atravessar etc.) e alertas sobre condições inseguras (piso escorregadio, alta tensão etc.)?",
      "Há um sistema de aterramento devidamente instalado nos depósitos  e periodicamente inspecionado?",
      "Há uma guarda de segurança para o controle da entrada e saída de pessoal, material e veículos?",
      "Há equipamento de respiração autônoma para utilização em casos de emergência?(*)",
      "Há algum tipo de alcalinizante, como barrilha ou cal para neutralização de vazamneto de HF",
      "Há guias de atendimento de primeiros socorros?(*)",
      "Há guias de atendimento médico?(*)",
      "Há Kit de primeiros socorros para atendimento de HF?(*)",

      "\n"
          "${jsonEncode(d)} \n"
          "Os produtos químicos controlados são guardados em local separado, exclusivo para este fim, devidamente identificados e tranca sob chaves ou outro dispositivo que ofereça segurança?",
      "Há um serviço diário de observação e registro das temperaturas máxima e mínima nos depósitos?",
      "Há um serviço diário de observação e registro do grau da umidade nos depósitos?",
      "Há um sistema de pára-raios devidamente instalados nos depósitos?",
      "Há uma guarda de segurança para o controle da entrada e saída de pessoal, material e veículos?",
      "Há alarmes sonoros e/ou luminosos estratégicamente instalados?",
      "Há cercas adequadas separando os pavilhões de fabricação, de administração e depósitos, em todo o seu perímetro?",
      "Há bacia ou dique de contenção em torno dos depósitos a granel capaz de reter vazamentos acidentais(*)",


    ];
    // Verificando se o tamanho da lista de respostas está sincronizado com o número de perguntas
    if (respostaExecucao.length < perguntas.length) {
      respostaExecucao = List.generate(perguntas.length, (index) => "");
    }
    if (observacoesExecucao.length < perguntas.length) {
      observacoesExecucao = List.generate(perguntas.length, (index) => "");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(perguntas.length, (index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pergunta
            Row(
              children: [
                Text("${index + 1} - ", style: TextStyle(
                  color: Color.fromRGBO(17, 48, 33, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
                Expanded(
                  child: Text(perguntas[index], style: TextStyle(
                    color: Color.fromRGBO(17, 48, 33, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Respostas de RadioListTile
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text("Sim", overflow: TextOverflow.ellipsis),
                        value: "Sim",
                        groupValue: respostaExecucao.length > index ? respostaExecucao[index] : null,
                        onChanged: (value) {
                          setState(() {
                            if (respostaExecucao.length > index) {
                              respostaExecucao[index] = value;
                            } else {
                              respostaExecucao.add(value);
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text("Não", overflow: TextOverflow.ellipsis),
                        value: "Não",
                        groupValue: respostaExecucao.length > index ? respostaExecucao[index] : null,
                        onChanged: (value) {
                          setState(() {
                            if (respostaExecucao.length > index) {
                              respostaExecucao[index] = value;
                            } else {
                              respostaExecucao.add(value);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                RadioListTile<String>(
                  title: Text(
                    "Não se Aplica",
                  ),
                  value: "Não se Aplica",
                  groupValue: respostaExecucao.length > index ? respostaExecucao[index] : null,
                  onChanged: (value) {
                    setState(() {
                      if (respostaExecucao.length > index) {
                        respostaExecucao[index] = value;
                      } else {
                        respostaExecucao.add(value);
                      }
                    });
                  },
                ),

              ],
            ),

            SizedBox(height: 10),

            // Observação
            Row(
              children: [
                Text("Observação:", style: TextStyle(
                  color: Color.fromRGBO(17, 48, 33, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
              ],
            ),
            SizedBox(height: 10),

            // Campo de texto para observação
            buildFormFieldEmpresa(
              "Detalhes da Observação",
              observacoesExecucao.length > index ? observacoesExecucao[index] : '',
              index,
                  (String value) {
                if (observacoesExecucao.length > index) {
                  observacoesExecucao[index] = value;
                } else {
                  observacoesExecucao.add(value);
                }
              },
            ),
            SizedBox(height: 10),
          ],
        );
      }),
    );
  }
  // Função auxiliar para construir campos de texto
  Widget buildFormFieldExecucao(String hint, String initialValue, int index, Function(String) onChanged) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: hint,
      ),
      onChanged: (value) {
        // Verifica se o campo foi deixado em branco ou não
        if (value.isEmpty && observacoesExecucao.length <= index) {
          // Se o campo foi deixado em branco, adicione "Não se Aplica"
          onChanged("S/A");
        } else {
          // Caso contrário, mantém o valor informado
          onChanged(value);
        }
      },
      controller: TextEditingController(text: initialValue.isEmpty ? "S/A" : initialValue),

    );
  }

  Widget buildExpansionDistancias_SegurancasTile() {
    return FutureBuilder<List<String>>(
      future: carregarDadosLocais(),
      builder: (context, snapshot) {
        bool temDadosNaoSalvos = snapshot.hasData && snapshot.data!.isNotEmpty;
        String titulo = temDadosNaoSalvos
            ? "Distâncias de Segurança (Registros não enviados)"
            : "Distâncias de Segurança";

        return Container(
          margin: EdgeInsets.only(bottom: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(243, 243, 243, 1.0),
                Color.fromRGBO(217, 217, 217, 1.0),
              ],
            ),
          ),
          child: ExpansionTile(
            title: Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            children: [
              if (temDadosNaoSalvos)
                Column(
                  children: snapshot.data!.map((dados) {
                    Map<String, dynamic> dadosMap = jsonDecode(dados);
                    return ListTile(
                      title: Text("Registro salvo localmente"),
                      subtitle: Text(
                            "Data: ${dadosMap['data'] ?? 'N/A'}\n"

                      ),
                      /*
                      trailing: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () async {
                          try {
                            List<String> imagensBase64 = [];

                            // Verifica se 'imagensBase64' existe e é uma lista
                            if (dadosMap['imagens'] != null && dadosMap['imagens'] is List) {
                              imagensBase64 = List<String>.from(dadosMap['imagens']);

                              // Adiciona nomes às imagens
                              imagensBase64 = imagensBase64
                                  .asMap()
                                  .entries
                                  .map((entry) => "Imagem_${entry.key + 1}: ${entry.value}")
                                  .toList();
                            }

                            // Debug: Exibe as imagens no console
                            print("Imagens encontradas para envio:");
                            imagensBase64.forEach((imagem) {
                              print(imagem.substring(0, 100)); // Exibe apenas os primeiros 100 caracteres
                            });

                            // Chama o método que envia os dados para o servidor
                            await enviarDadosParaServidor(
                              dadosMap['razaoSocial'] ?? '',
                              dadosMap['email'] ?? '',
                              (dadosMap['data'] ?? ''),
                              dadosMap['trcr'] ?? '',
                              dadosMap['endereco'] ?? '',
                              dadosMap['telefone'] ?? '',
                              dadosMap['telefoneResidencial'] ?? '',
                              dadosMap['cnpj'] ?? '',
                              dadosMap['respostaEmpresa'] ?? '',
                              dadosMap['observacoes'] ?? '',

                              dadosMap['campoNr_de_ord'] ?? '',
                              dadosMap['campoCodigo_pav_dep'] ?? '',
                              dadosMap['campoDestinacao'] ?? '',
                              dadosMap['campoBarricado'] ?? '',
                              dadosMap['campoDotacao'] ?? '',
                              dadosMap['campoEdificio_habitado'] ?? '',
                              dadosMap['campoFerrovia'] ?? '',
                              dadosMap['campoRodovia'] ?? '',
                              dadosMap['campoPredio_proximo'] ?? '',
                              dadosMap['campoCod_predio_proximo'] ?? '',

                              dadosMap['respostaExecucao'] ?? '',
                              dadosMap['observacoesExecucao'] ?? '',
                              dadosMap['lista_deficiencia'] ?? '',
                              dadosMap['observacoes_gerais'] ?? '',
                              dadosMap['infracao'] ?? '',
                              dadosMap['qtd_autos_infracao']?.isNotEmpty == true ? dadosMap['qtd_autos_infracao'] : '0',

                              dadosMap['qtd_termos_aprensao']?.isNotEmpty == true ? dadosMap['qtd_termos_aprensao'] : '0',
                              dadosMap['qtd_termos_depositario']?.isNotEmpty == true ? dadosMap['qtd_termos_depositario'] : '0',
                              dadosMap['especificar_deficiencias_encontradas'] ?? '',
                              dadosMap['prazo_deficiencias'] ?? '',
                              dadosMap['nome_fiscal_militar'] ?? '',
                              dadosMap['postoGraduacaoController'] ?? '',
                              dadosMap['idtMilitarController'] ?? '',
                              dadosMap['omMilitarController'] ?? '',
                              dadosMap['nome_empresa'] ?? '',
                              dadosMap['cpf_empresa'] ?? '',
                              dadosMap['testemunha1'] ?? '',
                              dadosMap['itdtestemunha1'] ?? '',
                              dadosMap['testemunha2'] ?? '',
                              dadosMap['itdtestemunha2'] ?? '',
                              dadosMap['assinatura1Base64'] ?? '',
                              dadosMap['assinatura2Base64'] ?? '',
                              dadosMap['assinatura3Base64'] ?? '',
                              dadosMap['assinatura4Base64'] ?? '',
                              imagensBase64,
                              jsonEncode(dadosMap['listaApreensao'] ?? []), // Convertendo lista de apreensão para JSON
                              jsonEncode(dadosMap['listaInfracao'] ?? []), // Convertendo lista de infração para JSON
                              jsonEncode(dadosMap['listaDepositario'] ?? []), // Convertendo lista de fiel depositário para JSON


                            );

                            // Após o envio, remove o registro local
                            print("Dados enviados com sucesso! Removendo registro local...");
                            await removerRegistroLocal(dados);
                          } catch (error, stackTrace) {
                            // Em caso de erro, exibe a mensagem e a pilha de erro
                            print("Erro ao enviar os dados: $error");
                            print("Detalhes: $stackTrace");
                          }
                        },
                      ),
                      */
                    );
                  }).toList(),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDistancias_SegurancaForm(),
                    SizedBox(height: 20),

                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildDistancias_SegurancaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildCamposDinamicos(),
        /*buildFormFieldComMascara("Nr de Ord:", nr_de_ord, numeroMask),
        SizedBox(height: 10,),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: buildFormField("N° ou código pav/dep :", codigo_pav_dep),
            ),
          ],
        ),
        SizedBox(height: 10,),
        buildFormFieldComMascara("Destinação:", destinacao, letrasMask),
        SizedBox(height: 10),
        Row(
          children: [

            Expanded(
              flex: 1,
              child: buildFormFieldComMascara("Barricado (S-N):", barricado, letrasMask),
            ),
          ],
        ),
        SizedBox(height: 10),
        buildFormFieldComMascara("Dotação:", dotacao, letrasMask),

        Text("Distância de Segurança (m)"),

        Row(
          children: [
            Expanded(
              flex: 1,
              child: buildFormFieldComMascara("Edifício Habitado:", edificio_habitado, letrasMask),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: buildFormFieldComMascara("Ferrovia:", ferrovia, letrasMask),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [

            Expanded(
              flex: 1,
              child: buildFormFieldComMascara("Rodovia:", rodovia, letrasMask),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: buildFormFieldComMascara("Prédio mais Próximo:", predio_proximo, letrasMask),
            ),
            SizedBox(width: 10,),
            Expanded(
              flex: 1,
              child: buildFormFieldComMascara("Código do prédio mais próximo:", cod_predio_proximo, letrasMask),
            ),
          ],
        ),*/

      ],


    );
  }

//Função para adicionar e remover campos
  Widget buildCamposDinamicos() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(243, 243, 243, 1.0),
            Color.fromRGBO(217, 217, 217, 1.0),
          ],
        ),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 300.0, // Altura máxima para a lista de campos
            ),
            child: ListView.builder(
              shrinkWrap: true, // Ajusta o tamanho da lista ao conteúdo
              itemCount: nr_de_ord.length,
              itemBuilder: (context, indice) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: nr_de_ord[indice],
                              decoration: InputDecoration(
                                labelText: 'Nr Ordem ${indice + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onChanged: (valor) => atualizarCampo(indice, valor),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: codigo_pav_dep[indice],
                              decoration: InputDecoration(
                                labelText: 'Código ${indice + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onChanged: (valor) => atualizarCampo1(indice, valor),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: destinacao[indice],
                              decoration: InputDecoration(
                                labelText: 'Destinação ${indice + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onChanged: (valor) => atualizarCampo2(indice, valor),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: barricado[indice],
                              decoration: InputDecoration(
                                labelText: 'Barricado ${indice + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onChanged: (valor) => atualizarCampo3(indice, valor),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: dotacao[indice],
                              decoration: InputDecoration(
                                labelText: 'Dotação ${indice + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onChanged: (valor) => atualizarCampo4(indice, valor),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: edificio_habitado[indice],
                              decoration: InputDecoration(
                                labelText: 'Edifício Habitado ${indice + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onChanged: (valor) => atualizarCampo5(indice, valor),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ferrovia[indice],
                              decoration: InputDecoration(
                                labelText: 'Ferrovia ${indice + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onChanged: (valor) => atualizarCampo6(indice, valor),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: rodovia[indice],
                              decoration: InputDecoration(
                                labelText: 'Rodovia ${indice + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onChanged: (valor) => atualizarCampo7(indice, valor),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: predio_proximo[indice],
                              decoration: InputDecoration(
                                labelText: 'Prédio Próximo ${indice + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onChanged: (valor) => atualizarCampo8(indice, valor),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: cod_predio_proximo[indice],
                              decoration: InputDecoration(
                                labelText: 'Código Prédio Próximo ${indice + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onChanged: (valor) => atualizarCampo9(indice, valor),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => removerCampo(indice),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: adicionarCampo,
                child: Text('Adicionar Campo'),
              ),
              /*ElevatedButton(
                onPressed: exibirCampos,
                child: Text('Exibir Valores'),
              ),*/
            ],
          ),
          SizedBox(height: 20),
          Text(
            "Se houver nenhum, ignore.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }




  //Formulário Lista de defiências encontradas
  Widget buildIdentificacaoDeficienciaTile() {
    return FutureBuilder<List<String>>(
      future: carregarDadosLocais(),
      builder: (context, snapshot) {
        bool temDadosNaoSalvos = snapshot.hasData && snapshot.data!.isNotEmpty;
        String titulo = temDadosNaoSalvos
            ? "Lista de Deficiências encontradas (Registros não enviados)"
            : "Lista de Deficiências encontradas";

        return Container(
          margin: EdgeInsets.only(bottom: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(243, 243, 243, 1.0),
                Color.fromRGBO(217, 217, 217, 1.0),
              ],
            ),
          ),
          child: ExpansionTile(
            title: Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            children: [
              if (temDadosNaoSalvos)
                Column(
                  children: snapshot.data!.map((dados) {
                    Map<String, dynamic> dadosMap = jsonDecode(dados);
                    return ListTile(
                      title: Text("Registro salvo localmente"),
                      subtitle: Text(
                        "Nome: ${dadosMap['nome']}\nEmail: ${dadosMap['email']}\nNúmero: ${dadosMap['numero']}",
                      ),
                      /*
                      trailing: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () async {
                          try {
                            List<String> imagensBase64 = [];

                            // Verifica se 'imagensBase64' existe e é uma lista
                            if (dadosMap['imagens'] != null && dadosMap['imagens'] is List) {
                              imagensBase64 = List<String>.from(dadosMap['imagens']);

                              // Adiciona nomes às imagens
                              imagensBase64 = imagensBase64
                                  .asMap()
                                  .entries
                                  .map((entry) => "Imagem_${entry.key + 1}: ${entry.value}")
                                  .toList();
                            }

                            // Debug: Exibe as imagens no console
                            print("Imagens encontradas para envio:");
                            imagensBase64.forEach((imagem) {
                              print(imagem.substring(0, 100)); // Exibe apenas os primeiros 100 caracteres
                            });

                            // Chama o método que envia os dados para o servidor
                            await enviarDadosParaServidor(
                              dadosMap['razaoSocial'] ?? '',
                              dadosMap['email'] ?? '',
                              (dadosMap['data'] ?? ''),
                              dadosMap['trcr'] ?? '',
                              dadosMap['endereco'] ?? '',
                              dadosMap['telefone'] ?? '',
                              dadosMap['telefoneResidencial'] ?? '',
                              dadosMap['cnpj'] ?? '',
                              dadosMap['respostaEmpresa'] ?? '',
                              dadosMap['observacoes'] ?? '',

                              dadosMap['campoNr_de_ord'] ?? '',
                              dadosMap['campoCodigo_pav_dep'] ?? '',
                              dadosMap['campoDestinacao'] ?? '',
                              dadosMap['campoBarricado'] ?? '',
                              dadosMap['campoDotacao'] ?? '',
                              dadosMap['campoEdificio_habitado'] ?? '',
                              dadosMap['campoFerrovia'] ?? '',
                              dadosMap['campoRodovia'] ?? '',
                              dadosMap['campoPredio_proximo'] ?? '',
                              dadosMap['campoCod_predio_proximo'] ?? '',

                              dadosMap['respostaExecucao'] ?? '',
                              dadosMap['observacoesExecucao'] ?? '',
                              dadosMap['lista_deficiencia'] ?? '',
                              dadosMap['observacoes_gerais'] ?? '',
                              dadosMap['infracao'] ?? '',
                              dadosMap['qtd_autos_infracao']?.isNotEmpty == true ? dadosMap['qtd_autos_infracao'] : '0',

                              dadosMap['qtd_termos_aprensao']?.isNotEmpty == true ? dadosMap['qtd_termos_aprensao'] : '0',
                              dadosMap['qtd_termos_depositario']?.isNotEmpty == true ? dadosMap['qtd_termos_depositario'] : '0',
                              dadosMap['especificar_deficiencias_encontradas'] ?? '',
                              dadosMap['prazo_deficiencias'] ?? '',
                              dadosMap['nome_fiscal_militar'] ?? '',
                              dadosMap['postoGraduacaoController'] ?? '',
                              dadosMap['idtMilitarController'] ?? '',
                              dadosMap['omMilitarController'] ?? '',
                              dadosMap['nome_empresa'] ?? '',
                              dadosMap['cpf_empresa'] ?? '',
                              dadosMap['testemunha1'] ?? '',
                              dadosMap['itdtestemunha1'] ?? '',
                              dadosMap['testemunha2'] ?? '',
                              dadosMap['itdtestemunha2'] ?? '',
                              dadosMap['assinatura1Base64'] ?? '',
                              dadosMap['assinatura2Base64'] ?? '',
                              dadosMap['assinatura3Base64'] ?? '',
                              dadosMap['assinatura4Base64'] ?? '',
                              imagensBase64,
                              jsonEncode(dadosMap['listaApreensao'] ?? []), // Convertendo lista de apreensão para JSON
                              jsonEncode(dadosMap['listaInfracao'] ?? []), // Convertendo lista de infração para JSON
                              jsonEncode(dadosMap['listaDepositario'] ?? []), // Convertendo lista de fiel depositário para JSON


                            );

                            // Após o envio, remove o registro local
                            print("Dados enviados com sucesso! Removendo registro local...");
                            await removerRegistroLocal(dados);
                          } catch (error, stackTrace) {
                            // Em caso de erro, exibe a mensagem e a pilha de erro
                            print("Erro ao enviar os dados: $error");
                            print("Detalhes: $stackTrace");
                          }
                        },
                      ),
                      */

                    );
                  }).toList(),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Listar as deficiências uma a uma, enumerando-as."),
                    SizedBox(height: 20,),
                    buildIdentificacaoDeficienciaForm(),



                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  //Construindo o formulário
  Widget buildIdentificacaoDeficienciaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFormFieldGrande(lista_deficiencia),
        SizedBox(height: 10,),
      ],
    );
  }

  //Formulário Observações gerais
  Widget buildIdentificacaoObservacoesGeraisTile() {
    return FutureBuilder<List<String>>(
      future: carregarDadosLocais(),
      builder: (context, snapshot) {
        bool temDadosNaoSalvos = snapshot.hasData && snapshot.data!.isNotEmpty;
        String titulo = temDadosNaoSalvos
            ? "Observações Gerais (Registros não enviados)"
            : "Observações Gerais";

        return Container(
          margin: EdgeInsets.only(bottom: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(243, 243, 243, 1.0),
                Color.fromRGBO(217, 217, 217, 1.0),
              ],
            ),
          ),
          child: ExpansionTile(
            title: Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            children: [
              if (temDadosNaoSalvos)
                Column(
                  children: snapshot.data!.map((dados) {
                    Map<String, dynamic> dadosMap = jsonDecode(dados);
                    return ListTile(
                      title: Text("Registro salvo localmente"),
                      subtitle: Text(
                        "Nome: ${dadosMap['nome']}\nEmail: ${dadosMap['email']}\nNúmero: ${dadosMap['numero']} \nTermos Apresencao: ${dadosMap['qtd_termos_aprensao']}" ,
                      ),
                      /*
                      trailing: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () async {
                          try {
                            List<String> imagensBase64 = [];

                            // Verifica se 'imagensBase64' existe e é uma lista
                            if (dadosMap['imagens'] != null && dadosMap['imagens'] is List) {
                              imagensBase64 = List<String>.from(dadosMap['imagens']);

                              // Adiciona nomes às imagens
                              imagensBase64 = imagensBase64
                                  .asMap()
                                  .entries
                                  .map((entry) => "Imagem_${entry.key + 1}: ${entry.value}")
                                  .toList();
                            }

                            // Debug: Exibe as imagens no console
                            print("Imagens encontradas para envio:");
                            imagensBase64.forEach((imagem) {
                              print(imagem.substring(0, 100)); // Exibe apenas os primeiros 100 caracteres
                            });

                            // Chama o método que envia os dados para o servidor
                            await enviarDadosParaServidor(
                              dadosMap['razaoSocial'] ?? '',
                              dadosMap['email'] ?? '',
                              (dadosMap['data'] ?? ''),
                              dadosMap['trcr'] ?? '',
                              dadosMap['endereco'] ?? '',
                              dadosMap['telefone'] ?? '',
                              dadosMap['telefoneResidencial'] ?? '',
                              dadosMap['cnpj'] ?? '',
                              dadosMap['respostaEmpresa'] ?? '',
                              dadosMap['observacoes'] ?? '',

                              dadosMap['campoNr_de_ord'] ?? '',
                              dadosMap['campoCodigo_pav_dep'] ?? '',
                              dadosMap['campoDestinacao'] ?? '',
                              dadosMap['campoBarricado'] ?? '',
                              dadosMap['campoDotacao'] ?? '',
                              dadosMap['campoEdificio_habitado'] ?? '',
                              dadosMap['campoFerrovia'] ?? '',
                              dadosMap['campoRodovia'] ?? '',
                              dadosMap['campoPredio_proximo'] ?? '',
                              dadosMap['campoCod_predio_proximo'] ?? '',

                              dadosMap['respostaExecucao'] ?? '',
                              dadosMap['observacoesExecucao'] ?? '',
                              dadosMap['lista_deficiencia'] ?? '',
                              dadosMap['observacoes_gerais'] ?? '',
                              dadosMap['infracao'] ?? '',
                              dadosMap['qtd_autos_infracao']?.isNotEmpty == true ? dadosMap['qtd_autos_infracao'] : '0',

                              dadosMap['qtd_termos_aprensao']?.isNotEmpty == true ? dadosMap['qtd_termos_aprensao'] : '0',
                              dadosMap['qtd_termos_depositario']?.isNotEmpty == true ? dadosMap['qtd_termos_depositario'] : '0',
                              dadosMap['especificar_deficiencias_encontradas'] ?? '',
                              dadosMap['prazo_deficiencias'] ?? '',
                              dadosMap['nome_fiscal_militar'] ?? '',
                              dadosMap['postoGraduacaoController'] ?? '',
                              dadosMap['idtMilitarController'] ?? '',
                              dadosMap['omMilitarController'] ?? '',
                              dadosMap['nome_empresa'] ?? '',
                              dadosMap['cpf_empresa'] ?? '',
                              dadosMap['testemunha1'] ?? '',
                              dadosMap['itdtestemunha1'] ?? '',
                              dadosMap['testemunha2'] ?? '',
                              dadosMap['itdtestemunha2'] ?? '',
                              dadosMap['assinatura1Base64'] ?? '',
                              dadosMap['assinatura2Base64'] ?? '',
                              dadosMap['assinatura3Base64'] ?? '',
                              dadosMap['assinatura4Base64'] ?? '',
                              imagensBase64,
                              jsonEncode(dadosMap['listaApreensao'] ?? []), // Convertendo lista de apreensão para JSON
                              jsonEncode(dadosMap['listaInfracao'] ?? []), // Convertendo lista de infração para JSON
                              jsonEncode(dadosMap['listaDepositario'] ?? []), // Convertendo lista de fiel depositário para JSON


                            );

                            // Após o envio, remove o registro local
                            print("Dados enviados com sucesso! Removendo registro local...");
                            await removerRegistroLocal(dados);
                          } catch (error, stackTrace) {
                            // Em caso de erro, exibe a mensagem e a pilha de erro
                            print("Erro ao enviar os dados: $error");
                            print("Detalhes: $stackTrace");
                          }
                        },
                      ),

                       */
                    );
                  }).toList(),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Demais observações e situações identificadas durante a inspeção"),
                    SizedBox(height: 20,),
                    buildIdentificacaoObservacoesGeraisForm(),



                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  //Construindo o formulário


  Widget buildIdentificacaoObservacoesGeraisForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFormFieldGrande(observacoes_gerais),
        SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: buildIdentificacaoObservacoesGeraisOpcoesForm(),
            ),
          ],
        ),

        if (infracao.isNotEmpty && infracao[0] == "Sim") ...[
          Row(
            children: [
              Text(
                "Se houve infração, informar:",
                style: TextStyle(
                  color: Color.fromRGBO(17, 48, 33, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          buildFormFieldComMascara(
            "Qnt de Autos de infração:",
            qtd_autos_infracao,
            numeroMask,
            readOnly: infracao[0] == "Não",
          ),
          SizedBox(height: 10),
          buildFormFieldComMascara(
            "Qnt de termos de apreensão:",
            qtd_termos_aprensao,
            numeroMask,
            readOnly: infracao[0] == "Não",
          ),
          SizedBox(height: 10),
          buildFormFieldComMascara(
            "Qnt de termos de fiel depositário:",
            qtd_termos_depositario,
            numeroMask,
            readOnly: infracao[0] == "Não",
          ),
          SizedBox(height: 10),
        ],
      ],
    );
  }
  Widget buildIdentificacaoObservacoesGeraisOpcoesForm() {
    List<String> perguntas = ["Houve infração"];

    if (infracao.length < perguntas.length) {
      infracao = List.generate(perguntas.length, (index) => "");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(perguntas.length, (index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    perguntas[index],
                    style: TextStyle(
                      color: Color.fromRGBO(17, 48, 33, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text("Sim"),
                    value: "Sim",
                    groupValue: infracao[index],
                    onChanged: (value) {
                      setState(() {
                        infracao[index] = value!;
                        // Limpa os campos quando "Sim" for selecionado
                        qtd_autos_infracao.clear();
                        qtd_termos_aprensao.clear();
                        qtd_termos_depositario.clear();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text("Não"),
                    value: "Não",
                    groupValue: infracao[index],
                    onChanged: (value) {
                      setState(() {
                        infracao[index] = value!;
                        // Bloqueia e limpa os campos quando "Não" for selecionado
                        qtd_autos_infracao.clear();
                        qtd_termos_aprensao.clear();
                        qtd_termos_depositario.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        );
      }),
    );
  }

  //Formulário Correção de defiências encontradas
  Widget buildIdentificacaoCorrecaoDeficienciaTile() {
    return FutureBuilder<List<String>>(
      future: carregarDadosLocais(),
      builder: (context, snapshot) {
        bool temDadosNaoSalvos = snapshot.hasData && snapshot.data!.isNotEmpty;
        String titulo = temDadosNaoSalvos
            ? "Correção de deficiências encontradas (Registros não enviados)"
            : "Correção de deficiências encontradas";

        return Container(
          margin: EdgeInsets.only(bottom: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(243, 243, 243, 1.0),
                Color.fromRGBO(217, 217, 217, 1.0),
              ],
            ),
          ),
          child: ExpansionTile(
            title: Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            children: [
              if (temDadosNaoSalvos)
                Column(
                  children: snapshot.data!.map((dados) {
                    Map<String, dynamic> dadosMap = jsonDecode(dados);
                    return ListTile(
                      title: Text("Registro salvo localmente"),
                      subtitle: Text(
                        "Nome: ${dadosMap['nome']}\nEmail: ${dadosMap['email']}\nNúmero: ${dadosMap['numero']}",
                      ),
                      /*
                      trailing: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () async {
                          try {
                            List<String> imagensBase64 = [];

                            // Verifica se 'imagensBase64' existe e é uma lista
                            if (dadosMap['imagens'] != null && dadosMap['imagens'] is List) {
                              imagensBase64 = List<String>.from(dadosMap['imagens']);

                              // Adiciona nomes às imagens
                              imagensBase64 = imagensBase64
                                  .asMap()
                                  .entries
                                  .map((entry) => "Imagem_${entry.key + 1}: ${entry.value}")
                                  .toList();
                            }

                            // Debug: Exibe as imagens no console
                            print("Imagens encontradas para envio:");
                            imagensBase64.forEach((imagem) {
                              print(imagem.substring(0, 100)); // Exibe apenas os primeiros 100 caracteres
                            });

                            // Chama o método que envia os dados para o servidor
                            await enviarDadosParaServidor(
                              dadosMap['razaoSocial'] ?? '',
                              dadosMap['email'] ?? '',
                              (dadosMap['data'] ?? ''),
                              dadosMap['trcr'] ?? '',
                              dadosMap['endereco'] ?? '',
                              dadosMap['telefone'] ?? '',
                              dadosMap['telefoneResidencial'] ?? '',
                              dadosMap['cnpj'] ?? '',
                              dadosMap['respostaEmpresa'] ?? '',
                              dadosMap['observacoes'] ?? '',

                              dadosMap['campoNr_de_ord'] ?? '',
                              dadosMap['campoCodigo_pav_dep'] ?? '',
                              dadosMap['campoDestinacao'] ?? '',
                              dadosMap['campoBarricado'] ?? '',
                              dadosMap['campoDotacao'] ?? '',
                              dadosMap['campoEdificio_habitado'] ?? '',
                              dadosMap['campoFerrovia'] ?? '',
                              dadosMap['campoRodovia'] ?? '',
                              dadosMap['campoPredio_proximo'] ?? '',
                              dadosMap['campoCod_predio_proximo'] ?? '',

                              dadosMap['respostaExecucao'] ?? '',
                              dadosMap['observacoesExecucao'] ?? '',
                              dadosMap['lista_deficiencia'] ?? '',
                              dadosMap['observacoes_gerais'] ?? '',
                              dadosMap['infracao'] ?? '',
                              dadosMap['qtd_autos_infracao']?.isNotEmpty == true ? dadosMap['qtd_autos_infracao'] : '0',

                              dadosMap['qtd_termos_aprensao']?.isNotEmpty == true ? dadosMap['qtd_termos_aprensao'] : '0',
                              dadosMap['qtd_termos_depositario']?.isNotEmpty == true ? dadosMap['qtd_termos_depositario'] : '0',
                              dadosMap['especificar_deficiencias_encontradas'] ?? '',
                              dadosMap['prazo_deficiencias'] ?? '',
                              dadosMap['nome_fiscal_militar'] ?? '',
                              dadosMap['postoGraduacaoController'] ?? '',
                              dadosMap['idtMilitarController'] ?? '',
                              dadosMap['omMilitarController'] ?? '',
                              dadosMap['nome_empresa'] ?? '',
                              dadosMap['cpf_empresa'] ?? '',
                              dadosMap['testemunha1'] ?? '',
                              dadosMap['itdtestemunha1'] ?? '',
                              dadosMap['testemunha2'] ?? '',
                              dadosMap['itdtestemunha2'] ?? '',
                              dadosMap['assinatura1Base64'] ?? '',
                              dadosMap['assinatura2Base64'] ?? '',
                              dadosMap['assinatura3Base64'] ?? '',
                              dadosMap['assinatura4Base64'] ?? '',
                              imagensBase64,
                              jsonEncode(dadosMap['listaApreensao'] ?? []), // Convertendo lista de apreensão para JSON
                              jsonEncode(dadosMap['listaInfracao'] ?? []), // Convertendo lista de infração para JSON
                              jsonEncode(dadosMap['listaDepositario'] ?? []), // Convertendo lista de fiel depositário para JSON


                            );

                            // Após o envio, remove o registro local
                            print("Dados enviados com sucesso! Removendo registro local...");
                            await removerRegistroLocal(dados);
                          } catch (error, stackTrace) {
                            // Em caso de erro, exibe a mensagem e a pilha de erro
                            print("Erro ao enviar os dados: $error");
                            print("Detalhes: $stackTrace");
                          }
                        },
                      ),

                       */
                    );
                  }).toList(),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10,),
                    buildIdentificacaoCorrecaoDeficienciaForm(),



                  ],

                ),
              ),
            ],
          ),
        );
      },
    );
  }
  //Construindo o formulário
  Widget buildIdentificacaoCorrecaoDeficienciaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child:
            Text("Nada a corrigir ou ", style: TextStyle(
                fontWeight: FontWeight.bold),),
            ),
            Expanded(
              child: buildFormField("", especificar_deficiencias_encontradas),
            ),
            Text(" (Especificar) ", style: TextStyle(
                fontWeight: FontWeight.bold),),
            SizedBox(width: 1,),
          ],
        ),
        SizedBox(height: 10,),
        Row(
          children: [
            Expanded(child:
            Text("Fica estabelecido o prazo de", style: TextStyle(
                fontWeight: FontWeight.bold),
            ),
              flex: 3,
            ),
            Expanded(
              child:
              buildFormField("",prazo_deficiencias),
              flex: 2,
            ),
            Expanded(
              child:
              Text(""),
              flex: 2,
            ),
          ],
        ),
        Row(
          children: [
            Expanded(child:
            Text("dias para que o fiscalizado providencie a correção das deficiências apontadas no item 4. LISTA DE DEFICIÊNCIAS ENCONTRADAS", style: TextStyle(
                fontWeight: FontWeight.bold),),),
            SizedBox(height: 10),
          ],
        ),
        SizedBox(height: 10,),
      ],
    );
  }

  //Controllers e Mascaras
  Widget buildFormField(String labelText, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Color.fromRGBO(17, 48, 33, 1),
          fontFamily: 'RobotoMono',
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(17, 48, 33, 1)),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(17, 48, 33, 1)),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      style: TextStyle(color: Color.fromRGBO(17, 48, 33, 1)),
    );
  }
  Widget buildFormFieldGrande(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        labelStyle: TextStyle(
          color: Color.fromRGBO(17, 48, 33, 1),
          fontFamily: 'RobotoMono',
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(17, 48, 33, 1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(17, 48, 33, 1)),
        ),
      ),
      style: TextStyle(color: Color.fromRGBO(17, 48, 33, 1)),
    );
  }

  Widget buildFormFieldComMascaraData(String labelText, TextEditingController controller, MaskTextInputFormatter mask) {
// Inicializa o campo com a data atual formatada
    controller.text = getCurrentDateFormatted(); // Define o valor da data

    return TextFormField(
      controller: controller,
      inputFormatters: [mask],
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Color.fromRGBO(17, 48, 33, 1),
          fontFamily: 'RobotoMono',
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(17, 48, 33, 1)),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(17, 48, 33, 1)),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      style: TextStyle(color: Color.fromRGBO(17, 48, 33, 1)),
    );
  }
  Widget buildFormFieldComMascara(
      String labelText,
      TextEditingController controller,
      MaskTextInputFormatter mask, {
        bool readOnly = false, // Adiciona a opção de bloquear o campo
      }) {
    return TextFormField(
      controller: controller,
      inputFormatters: [mask],
      readOnly: readOnly, // Define se o campo pode ser editado
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Color.fromRGBO(17, 48, 33, 1),
          fontFamily: 'RobotoMono',
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(17, 48, 33, 1)),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(17, 48, 33, 1)),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      style: TextStyle(color: Color.fromRGBO(17, 48, 33, 1)),
    );
  }

  void exibirPopupTermosApreensao(BuildContext context, int qtdTermos, int qtdTermosIfracao, int qtdTermosDepositario) {
// Garante que a lista de apreensões tenha pelo menos `qtdTermos` elementos
    while (apreensoes.length < qtdTermos) {
      apreensoes.add({
        "data_hora": TextEditingController(text: getCurrentDateTimeFormatted()),
        "estadoIdSelecionado": null,
        "cidade": TextEditingController(),
        "produtos": [],
      });
    }

// Garante que a lista de infrações tenha pelo menos `qtdTermosIfracao` elementos
    while (infracoes.length < qtdTermosIfracao) {
      infracoes.add({
        "data_hora_infracao": TextEditingController(text: getCurrentDateTimeFormatted()),
        "estadoIdSelecionado_infracao": null,
        "cidade_infracao": TextEditingController(),
        "produtos_infracao": [],
      });
    }

// Garante que a lista de depositários tenha pelo menos `qtdTermosDepositario` elementos
    while (depositarios.length < qtdTermosDepositario) {
      depositarios.add({
        "data_hora_depositario": TextEditingController(text: getCurrentDateTimeFormatted()),
        "estadoIdSelecionado_depositario": null,
        "cidade_depositario": TextEditingController(),
        "produtos_depositario": [],
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Preencha os Termos"),
              content: Container(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
// Exibir formulários de apreensão
                      if (apreensoes.isNotEmpty)
                        Column(
                          children: [
                            Text("Termos de Apreensão", style: TextStyle(fontWeight: FontWeight.bold)),
                            ...List.generate(qtdTermos, (index) {
                              return construirFormularioApreensao(index, setState);
                            }),
                          ],
                        ),

                      SizedBox(height: 20),

// Exibir formulários de infração
                      if (infracoes.isNotEmpty)
                        Column(
                          children: [
                            Text("Termos de Infração", style: TextStyle(fontWeight: FontWeight.bold)),
                            ...List.generate(qtdTermosIfracao, (index) {
                              return construirFormularioInfracao(index, setState);
                            }),
                          ],
                        ),

                      SizedBox(height: 20),

// Exibir formulários de fiel depositário
                      if (depositarios.isNotEmpty)
                        Column(
                          children: [
                            Text("Termos de Fiel Depositário", style: TextStyle(fontWeight: FontWeight.bold)),
                            ...List.generate(qtdTermosDepositario, (index) {
                              return construirFormularioDepositario(index, setState);
                            }),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    enviarDadosFormulario(context);
                  },
                  child: Text("Salvar"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Widget construirFormularioInfracao(int index, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data e Hora:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(
          controller: infracoes[index]["data_hora_infracao"],
          decoration: InputDecoration(labelText: "Data e Hora"),
        ),
        SizedBox(height: 10),

        Text('Estado:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        DropdownButton<int>(
          value: infracoes[index]["estadoIdSelecionado_infracao"],
          items: estados.map((estado) {
            return DropdownMenuItem<int>(
              value: estado['id'],
              child: Text(estado['nome']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              infracoes[index]["estadoIdSelecionado_infracao"] = value;
            });
          },
        ),
        SizedBox(height: 10),

        Text('Cidade:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(
          controller: infracoes[index]["cidade_infracao"],
          decoration: InputDecoration(labelText: "Cidade"),
        ),
        SizedBox(height: 10),

        Text('Produtos:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ListView.builder(
          shrinkWrap: true,
          itemCount: (infracoes[index]["produtos_infracao"] ?? []).length,
          itemBuilder: (context, prodIndex) {
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: infracoes[index]["produtos_infracao"][prodIndex]["produto_infracao"],
                    decoration: InputDecoration(labelText: "Produto"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      if (infracoes[index]["produtos_infracao"] != null &&
                          infracoes[index]["produtos_infracao"].isNotEmpty) {
                        infracoes[index]["produtos_infracao"].removeAt(prodIndex);
                      }
                    });
                  },
                ),
              ],
            );
          },
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              infracoes[index]["produtos_infracao"] ??= [];
              infracoes[index]["produtos_infracao"].add({
                "produto_infracao": TextEditingController(),
                "qtdApreensao_infracao": TextEditingController(),
                "unidade_infracao": TextEditingController(),
                "tipo_infracao": TextEditingController(),
                "marca_infracao": TextEditingController(),
                "obs_infracao": TextEditingController(),
              });
            });
          },
          child: Text("Adicionar Produto"),
        ),
        Divider(),
      ],
    );
  }
  Widget construirFormularioApreensao(int index, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data e Hora:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(
          controller: apreensoes[index]["data_hora"],
          decoration: InputDecoration(labelText: "Data e Hora"),
        ),
        SizedBox(height: 10),

        Text('Estado:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        DropdownButton<int>(
          value: apreensoes[index]["estadoIdSelecionado"],
          items: estados.map((estado) {
            return DropdownMenuItem<int>(
              value: estado['id'],
              child: Text(estado['nome']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              apreensoes[index]["estadoIdSelecionado"] = value;
            });
          },
        ),
        SizedBox(height: 10),

        Text('Cidade:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(
          controller: apreensoes[index]["cidade"],
          decoration: InputDecoration(labelText: "Cidade"),
        ),
        SizedBox(height: 10),

        Text('Produtos:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ListView.builder(
          shrinkWrap: true,
          itemCount: apreensoes[index]["produtos"].length,
          itemBuilder: (context, prodIndex) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: apreensoes[index]["produtos"][prodIndex]["produto"],
                        decoration: InputDecoration(labelText: "Produto"),
                      ),
                    ),
                    SizedBox(width: 8), // Espaço entre os campos
                    Expanded(
                      child: TextField(
                        controller: apreensoes[index]["produtos"][prodIndex]["qtdApreensao"],
                        decoration: InputDecoration(labelText: "Qtd"),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          apreensoes[index]["produtos"].removeAt(prodIndex);
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: apreensoes[index]["produtos"][prodIndex]["unidade"],
                        decoration: InputDecoration(labelText: "Unidade"),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: apreensoes[index]["produtos"][prodIndex]["tipo"],
                        decoration: InputDecoration(labelText: "Tipo"),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          apreensoes[index]["produtos"].removeAt(prodIndex);
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: apreensoes[index]["produtos"][prodIndex]["marca"],
                        decoration: InputDecoration(labelText: "Marca"),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: apreensoes[index]["produtos"][prodIndex]["obs"],
                        decoration: InputDecoration(labelText: "Obs"),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          apreensoes[index]["produtos"].removeAt(prodIndex);
                        });
                      },
                    ),
                  ],
                ),
                Divider(),
              ],
            );
          },
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              apreensoes[index]["produtos"].add({
                "produto": TextEditingController(),
                "qtdApreensao": TextEditingController(),
                "unidade": TextEditingController(),
                "tipo": TextEditingController(),
                "marca": TextEditingController(),
                "obs": TextEditingController(),
              });
            });
          },
          child: Text("Adicionar Produto"),
        ),
        Divider(),

      ],
    );
  }
  Widget construirFormularioDepositario(int index, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data e Hora:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(
          controller: depositarios[index]["data_hora_depositario"] ??= TextEditingController(),
          decoration: InputDecoration(labelText: "Data e Hora"),
        ),
        SizedBox(height: 10),

        Text('Estado:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        DropdownButton<int>(
          value: depositarios[index]["estadoIdSelecionado_depositario"],
          items: estados.map((estado) {
            return DropdownMenuItem<int>(
              value: estado['id'],
              child: Text(estado['nome']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              depositarios[index]["estadoIdSelecionado_depositario"] = value;
            });
          },
        ),



        Text('Cidade:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(
          controller: depositarios[index]["cidade_depositario"] ??= TextEditingController(),
          decoration: InputDecoration(labelText: "Cidade"),
        ),
        SizedBox(height: 10),

        Text('Produtos:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: depositarios[index]["produtos_depositario"]?.length ?? 0,
          itemBuilder: (context, prodIndex) {
            var produto = depositarios[index]["produtos_depositario"][prodIndex];

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: produto["produto_depositario"] ??= TextEditingController(),
                        decoration: InputDecoration(labelText: "Produto"),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: produto["qtdApreensao_depositario"] ??= TextEditingController(),
                        decoration: InputDecoration(labelText: "Qtd"),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          depositarios[index]["produtos_depositario"].removeAt(prodIndex);
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: produto["unidade_depositario"] ??= TextEditingController(),
                        decoration: InputDecoration(labelText: "Unidade"),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: produto["tipo_depositario"] ??= TextEditingController(),
                        decoration: InputDecoration(labelText: "Tipo"),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: produto["marca_depositario"] ??= TextEditingController(),
                        decoration: InputDecoration(labelText: "Marca"),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: produto["obs_depositario"] ??= TextEditingController(),
                        decoration: InputDecoration(labelText: "Obs"),
                      ),
                    ),
                  ],
                ),
                Divider(),
              ],
            );
          },
        ),

        ElevatedButton(
          onPressed: () {
            setState(() {
              depositarios[index]["produtos_depositario"] ??= [];
              depositarios[index]["produtos_depositario"].add({
                "produto_depositario": TextEditingController(),
                "qtdApreensao_depositario": TextEditingController(),
                "unidade_depositario": TextEditingController(),
                "tipo_depositario": TextEditingController(),
                "marca_depositario": TextEditingController(),
                "obs_depositario": TextEditingController(),
              });
            });
          },
          child: Text("Adicionar Produto"),
        ),
        Divider(),
      ],
    );
  }

}
