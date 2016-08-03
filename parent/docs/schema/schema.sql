-- ##############################################################
-- sequencia
-- ##############################################################
CREATE TABLE sicar.sequencia
(
  sequencia NUMERIC(2,0)  NOT NULL,
  currval   NUMERIC(18,0) NOT NULL,
  nextval   NUMERIC(18,0) NOT NULL,
  step      NUMERIC(2,0)  NOT NULL,
  descricao CHARACTER VARYING(60) NOT NULL,

  CONSTRAINT sequencia_pkey PRIMARY KEY (sequencia)
);
-- ##############################################################
-- f_seq_nextval
-- ##############################################################
CREATE OR REPLACE FUNCTION sicar.f_seq_nextval(p_sequencia integer)
  RETURNS numeric AS
$BODY$DECLARE
  v_currval NUMERIC(18, 0) := 0;
  v_nextval NUMERIC(18, 0) := 0;
BEGIN
  -- Obtém o próximo ID
  SELECT currval, nextval
  INTO v_currval, v_nextval
  FROM sicar.sequencia
  WHERE sequencia = p_sequencia;

  -- Atualiza a sequencia específica
  UPDATE sicar.sequencia
  SET currval = v_nextval,
      nextval = v_nextval + step
  WHERE sequencia = p_sequencia;

  -- Define o valor na propriedade de Saída
  RETURN v_nextval;
END;$BODY$
LANGUAGE plpgsql;
-- ##############################################################
-- f_calcula_saldo
-- ##############################################################
CREATE OR REPLACE FUNCTION sicar.f_gerar_saldo(p_conta integer, p_periodo_anterior integer, p_periodo integer)
  RETURNS void AS
$BODY$DECLARE
  v_saldo_anterior         NUMERIC(12, 2) := 0;
  v_receita                NUMERIC(12, 2) := 0;
  v_transf_entrada         NUMERIC(12, 2) := 0;
  v_transf_saida           NUMERIC(12, 2) := 0;
  v_investimento           NUMERIC(12, 2) := 0;
  v_despesa_fixa           NUMERIC(12, 2) := 0;
  v_despesa_variavel       NUMERIC(12, 2) := 0;
  v_despesa_adicional      NUMERIC(12, 2) := 0;
  v_despesa_extraordinaria NUMERIC(12, 2) := 0;
  v_saldo_final            NUMERIC(12, 2) := 0;
BEGIN
  -- Excluí o saldo caso exista
  DELETE FROM sicar.conta_saldo WHERE conta = p_conta AND periodo = p_periodo;

  -- Saldo Inicial
  SELECT cs.saldo_final
    INTO v_saldo_anterior
    FROM sicar.conta_saldo cs 
   WHERE cs.conta = p_conta 
     AND cs.periodo = p_periodo_anterior;
     
  -- Receita
  SELECT coalesce(abs(sum(m.valor * o.sinal)), 0)
    INTO v_receita
    FROM sicar.movimento m, sicar.operacao o
   WHERE m.conta = p_conta
     AND to_char(m.data_liquidacao, 'YYYYMM')::integer = p_periodo
     AND m.operacao = o.operacao
     AND m.categoria in (SELECT c.categoria 
                           FROM sicar.categoria c 
                          WHERE c.conceito = 0);
     
  -- Entrada de Fundos
  SELECT coalesce(abs(sum(m.valor * o.sinal)), 0)
    INTO v_transf_entrada
    FROM sicar.movimento m, sicar.operacao o
   WHERE m.conta = p_conta
     AND to_char(m.data_liquidacao, 'YYYYMM')::integer = p_periodo
     AND m.operacao = o.operacao
     AND m.categoria in (SELECT c.categoria 
                           FROM sicar.categoria c 
                          WHERE c.conceito = 6 
                            AND c.descricao = 'Entrada de Fundos');
     
  -- Saída de Fundos
  SELECT coalesce(abs(sum(m.valor * o.sinal)), 0)
    INTO v_transf_saida
    FROM sicar.movimento m, sicar.operacao o
   WHERE m.conta = p_conta
     AND to_char(m.data_liquidacao, 'YYYYMM')::integer = p_periodo
     AND m.operacao = o.operacao
     AND m.categoria in (SELECT c.categoria 
                           FROM sicar.categoria c 
                          WHERE c.conceito = 6 
                            AND c.descricao = 'Saída de Fundos');
     
  -- Investimento
  SELECT coalesce(abs(sum(m.valor * o.sinal)), 0)
    INTO v_investimento
    FROM sicar.movimento m, sicar.operacao o
   WHERE m.conta = p_conta
     AND to_char(m.data_liquidacao, 'YYYYMM')::integer = p_periodo
     AND m.operacao = o.operacao
     AND m.categoria in (SELECT c.categoria 
                           FROM sicar.categoria c 
                          WHERE c.conceito = 1);
     
  -- Despesa Fixa
  SELECT coalesce(abs(sum(m.valor * o.sinal)), 0)
    INTO v_despesa_fixa
    FROM sicar.movimento m, sicar.operacao o
   WHERE m.conta = p_conta
     AND to_char(m.data_liquidacao, 'YYYYMM')::integer = p_periodo
     AND m.operacao = o.operacao
     AND m.categoria in (SELECT c.categoria 
                           FROM sicar.categoria c 
                          WHERE c.conceito = 2);
     
  -- Despesa Variável
  SELECT coalesce(abs(sum(m.valor * o.sinal)), 0)
    INTO v_despesa_variavel
    FROM sicar.movimento m, sicar.operacao o
   WHERE m.conta = p_conta
     AND to_char(m.data_liquidacao, 'YYYYMM')::integer = p_periodo
     AND m.operacao = o.operacao
     AND m.categoria in (SELECT c.categoria 
                           FROM sicar.categoria c 
                          WHERE c.conceito = 3);

  -- Despesa Adicional
  SELECT coalesce(abs(sum(m.valor * o.sinal)), 0)
    INTO v_despesa_adicional
    FROM sicar.movimento m, sicar.operacao o
   WHERE m.conta = p_conta
     AND to_char(m.data_liquidacao, 'YYYYMM')::integer = p_periodo
     AND m.operacao = o.operacao
     AND m.categoria in (SELECT c.categoria 
                           FROM sicar.categoria c 
                          WHERE c.conceito = 4);

  -- Despesa Extraordinária
  SELECT coalesce(abs(sum(m.valor * o.sinal)), 0)
    INTO v_despesa_extraordinaria
    FROM sicar.movimento m, sicar.operacao o
   WHERE m.conta = p_conta
     AND to_char(m.data_liquidacao, 'YYYYMM')::integer = p_periodo
     AND m.operacao = o.operacao
     AND m.categoria in (SELECT c.categoria 
                           FROM sicar.categoria c 
                          WHERE c.conceito = 5);
                          
  -- Grava o registro de saldo para o Período
  INSERT INTO sicar.conta_saldo VALUES (p_conta, 
					p_periodo, 
					v_saldo_anterior, 
					v_receita,
          v_transf_entrada,
          v_transf_saida,
					v_investimento, 
					v_despesa_fixa, 
					v_despesa_variavel, 
					v_despesa_adicional, 
					v_despesa_extraordinaria, 
					(v_saldo_anterior + v_receita + v_transf_entrada) - (v_investimento + v_transf_saida + v_despesa_fixa + v_despesa_variavel + v_despesa_adicional + v_despesa_extraordinaria));

  -- Retorna o vazio
  RETURN;
END;$BODY$
LANGUAGE plpgsql;
-- ##############################################################
-- operacao
-- ##############################################################
CREATE TABLE sicar.operacao
(
  operacao  NUMERIC(1,0) NOT NULL,
  sinal     NUMERIC(1,0) NOT NULL,
  descricao CHARACTER VARYING(7) NOT NULL,

  CONSTRAINT operacao_pkey PRIMARY KEY (operacao)
);

INSERT INTO sicar.operacao VALUES (0, 1, 'CREDITO');
INSERT INTO sicar.operacao VALUES (1, -1, 'DEBITO');
-- ##############################################################
-- conceito
-- ##############################################################
CREATE TABLE sicar.conceito
(
  conceito  NUMERIC(1,0) NOT NULL,
  nome      CHARACTER VARYING(30) NOT NULL,
  descricao CHARACTER VARYING(100) NOT NULL,

  CONSTRAINT conceito_pkey PRIMARY KEY (conceito)
);

INSERT INTO sicar.conceito VALUES (0, 'RECEITA', 'Entrada de Capital');
INSERT INTO sicar.conceito VALUES (1, 'INVESTIMENTO', 'Aplicação em Investimentos Financeiros');
INSERT INTO sicar.conceito VALUES (2, 'DESPESA FIXA', 'Despesas que tem o mesmo montante todos os meses');
INSERT INTO sicar.conceito VALUES (3, 'DESPESA VARIÁVEL', 'Despesas que acontecem todos os meses mas o valor pode variar');
INSERT INTO sicar.conceito VALUES (4, 'DESPESA ADICIONAL', 'Despesas que não precisam ocorrer todos os meses');
INSERT INTO sicar.conceito VALUES (5, 'DESPESA EXTRAORDINÁRIA', 'Despesas inesperadas que devemos estar preparados quando acontecerem');
INSERT INTO sicar.conceito VALUES (6, 'TRANSFERÊNCIA', 'Transferência de fundos entre contas');
-- ##############################################################
-- categoria
-- ##############################################################
CREATE TABLE sicar.categoria
(
  categoria NUMERIC(12,0) NOT NULL,
  conceito  NUMERIC(1,0) NOT NULL,
  parent    NUMERIC(12,0),
  descricao CHARACTER VARYING(30) NOT NULL,

  CONSTRAINT categoria_pkey PRIMARY KEY (categoria),

  CONSTRAINT categoria_fk_conceito FOREIGN KEY (conceito)
  REFERENCES sicar.conceito (conceito) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- Trigger Function
INSERT INTO sicar.sequencia VALUES (3, 0, 1, 1, 'Categoria ID');

-- RECEITA

INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, null, 'Trabalho');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Trabalho' AND c.conceito = 0 AND parent IS NULL), 'Salário');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Trabalho' AND c.conceito = 0 AND parent IS NULL), 'Salário Adicional');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Trabalho' AND c.conceito = 0 AND parent IS NULL), '13ro Salário');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Trabalho' AND c.conceito = 0 AND parent IS NULL), 'Férias');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, null, 'Investimento');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Investimento' AND c.conceito = 0 AND parent IS NULL), 'Resgate de Investimento');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Investimento' AND c.conceito = 0 AND parent IS NULL), 'Rendimento de Investimento');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Investimento' AND c.conceito = 0 AND parent IS NULL), 'Aplicação na Poupança');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Investimento' AND c.conceito = 0 AND parent IS NULL), 'Aplicação em Fundo');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, null, 'Benefícios');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Benefícios' AND c.conceito = 0 AND parent IS NULL), 'PIS');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Benefícios' AND c.conceito = 0 AND parent IS NULL), 'Seguro Desemprego');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Benefícios' AND c.conceito = 0 AND parent IS NULL), 'Restituição IRPF');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, null, 'Diversos');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Diversos' AND c.conceito = 0 AND parent IS NULL), 'Aluguél');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Diversos' AND c.conceito = 0 AND parent IS NULL), 'Serviços');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Diversos' AND c.conceito = 0 AND parent IS NULL), 'Vendas');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 0, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Diversos' AND c.conceito = 0 AND parent IS NULL), 'Outros');

-- INVESTIMENTO
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 1, null, 'Fundo de Investimento');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 1, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Fundo de Investimento' AND c.conceito = 1 AND parent IS NULL), 'Aplicação na Poupança');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 1, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Fundo de Investimento' AND c.conceito = 1 AND parent IS NULL), 'Aplicação em Fundo');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 1, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Fundo de Investimento' AND c.conceito = 1 AND parent IS NULL), 'Resgate de Fundos');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 1, null, 'Bolsa de Valores');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 1, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Bolsa de Valores' AND c.conceito = 1 AND parent IS NULL), 'Compra de Ações');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 1, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Bolsa de Valores' AND c.conceito = 1 AND parent IS NULL), 'Venda de Ações');

-- DESPESA FIXA
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, null, 'Habitação');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 2 AND parent IS NULL), 'Aluguél');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 2 AND parent IS NULL), 'Condomínio');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 2 AND parent IS NULL), 'Prestação de Casa');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 2 AND parent IS NULL), 'Seguro de Casa');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 2 AND parent IS NULL), 'Diarista');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 2 AND parent IS NULL), 'Mensalista');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 2 AND parent IS NULL), 'IPTU');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, null, 'Transporte');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Transporte' AND c.conceito = 2 AND parent IS NULL), 'Parcela Automóvel');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Transporte' AND c.conceito = 2 AND parent IS NULL), 'Segudo Automóvel');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Transporte' AND c.conceito = 2 AND parent IS NULL), 'Estacionamento');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Transporte' AND c.conceito = 2 AND parent IS NULL), 'IPVA');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, null, 'Saúde');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Saúde' AND c.conceito = 2 AND parent IS NULL), 'Plano de Saúde');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Saúde' AND c.conceito = 2 AND parent IS NULL), 'Seguro de Vida');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, null, 'Educação');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Educação' AND c.conceito = 2 AND parent IS NULL), 'Colégio');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Educação' AND c.conceito = 2 AND parent IS NULL), 'Faculdade');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Educação' AND c.conceito = 2 AND parent IS NULL), 'Pós Graduação');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Educação' AND c.conceito = 2 AND parent IS NULL), 'Mestrado');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Educação' AND c.conceito = 2 AND parent IS NULL), 'Doutorado');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Educação' AND c.conceito = 2 AND parent IS NULL), 'Curso');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, null, 'Outros');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Outros' AND c.conceito = 2 AND parent IS NULL), 'Dizimo');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Outros' AND c.conceito = 2 AND parent IS NULL), 'Oferta');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 2, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Outros' AND c.conceito = 2 AND parent IS NULL), 'Serviços');

-- DESPESA VARIAVEL
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, null, 'Habitação');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 3 AND parent IS NULL), 'Luz');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 3 AND parent IS NULL), 'Água');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 3 AND parent IS NULL), 'Gâs');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 3 AND parent IS NULL), 'Telefone Fixo');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 3 AND parent IS NULL), 'Telefone Celular');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 3 AND parent IS NULL), 'TV à cabo');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 3 AND parent IS NULL), 'Internet');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, null, 'Transporte');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Transporte' AND c.conceito = 3 AND parent IS NULL), 'Metrô');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Transporte' AND c.conceito = 3 AND parent IS NULL), 'ônibus');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Transporte' AND c.conceito = 3 AND parent IS NULL), 'Combustível');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Transporte' AND c.conceito = 3 AND parent IS NULL), 'Estacionamento');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, null, 'Alimentação');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Alimentação' AND c.conceito = 3 AND parent IS NULL), 'Supermercado');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Alimentação' AND c.conceito = 3 AND parent IS NULL), 'Mercado');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Alimentação' AND c.conceito = 3 AND parent IS NULL), 'Padaria');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Alimentação' AND c.conceito = 3 AND parent IS NULL), 'Açougue');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Alimentação' AND c.conceito = 3 AND parent IS NULL), 'Feira');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, null, 'Cuidados Pessoais');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Cuidados Pessoais' AND c.conceito = 3 AND parent IS NULL), 'Academia');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Cuidados Pessoais' AND c.conceito = 3 AND parent IS NULL), 'Estética');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, null, 'Saúde');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Saúde' AND c.conceito = 3 AND parent IS NULL), 'Médico');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Saúde' AND c.conceito = 3 AND parent IS NULL), 'Medicamentos');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Saúde' AND c.conceito = 3 AND parent IS NULL), 'Dentista');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Saúde' AND c.conceito = 3 AND parent IS NULL), 'Hospital');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, null, 'Outros');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Outros' AND c.conceito = 3 AND parent IS NULL), 'Cartão de Crédito');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 3, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Outros' AND c.conceito = 3 AND parent IS NULL), 'Taxas Bancárias');

-- DESPESA ADICIONAL
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 4, null, 'Lazer');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 4, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Lazer' AND c.conceito = 4 AND parent IS NULL), 'Viagem');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 4, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Lazer' AND c.conceito = 4 AND parent IS NULL), 'Cinema/Teatro');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 4, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Lazer' AND c.conceito = 4 AND parent IS NULL), 'Revistas/Livros');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 4, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Lazer' AND c.conceito = 4 AND parent IS NULL), 'CD/DVD');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 4, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Lazer' AND c.conceito = 4 AND parent IS NULL), 'Restaurante/Bar');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 4, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Lazer' AND c.conceito = 4 AND parent IS NULL), 'Clube');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 4, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Lazer' AND c.conceito = 4 AND parent IS NULL), 'Locação de Vídeo');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 4, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Lazer' AND c.conceito = 4 AND parent IS NULL), 'Hobby');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 4, null, 'Vestuário');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 4, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Vestuário' AND c.conceito = 4 AND parent IS NULL), 'Roupa');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 4, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Vestuário' AND c.conceito = 4 AND parent IS NULL), 'Calçado');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 4, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Vestuário' AND c.conceito = 4 AND parent IS NULL), 'Acessório');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 4, null, 'Outros');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 4, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Outros' AND c.conceito = 4 AND parent IS NULL), 'Saque');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 4, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Outros' AND c.conceito = 4 AND parent IS NULL), 'Presente');

-- DESPESA EXTRAORDINÁRIA
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, null, 'Saúde');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Saúde' AND c.conceito = 5 AND parent IS NULL), 'Médico');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Saúde' AND c.conceito = 5 AND parent IS NULL), 'Medicamentos');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Saúde' AND c.conceito = 5 AND parent IS NULL), 'Dentista');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Saúde' AND c.conceito = 5 AND parent IS NULL), 'Hospital');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, null, 'Habitação');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 5 AND parent IS NULL), 'Móveis');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 5 AND parent IS NULL), 'Decoração');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 5 AND parent IS NULL), 'Reparos');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Habitação' AND c.conceito = 5 AND parent IS NULL), 'Itens do Lar');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, null, 'Transporte');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Transporte' AND c.conceito = 5 AND parent IS NULL), 'Manutenção Carro');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Transporte' AND c.conceito = 5 AND parent IS NULL), 'Estacionamento');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Transporte' AND c.conceito = 5 AND parent IS NULL), 'Imposto & Tarifa');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, null, 'Educação');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Educação' AND c.conceito = 5 AND parent IS NULL), 'Material escolar');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Educação' AND c.conceito = 5 AND parent IS NULL), 'Uniforme');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, null, 'Ivestimento');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Ivestimento' AND c.conceito = 5 AND parent IS NULL), 'Prejuízo de Investimento');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, null, 'Outros');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Outros' AND c.conceito = 5 AND parent IS NULL), 'Emprestimo');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Outros' AND c.conceito = 5 AND parent IS NULL), 'Correios');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 5, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Outros' AND c.conceito = 5 AND parent IS NULL), 'Pagamentos');

-- Transferência
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 6, null, 'Transferência de Fundos');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 6, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Transferência de Fundos' AND c.conceito = 6 AND parent IS NULL), 'Entrada de Fundos');
INSERT INTO sicar.categoria VALUES ((SELECT sicar.f_seq_nextval(3)), 6, (SELECT c.categoria FROM sicar.categoria c WHERE c.descricao = 'Transferência de Fundos' AND c.conceito = 6 AND parent IS NULL), 'Saída de Fundos');

-- ##############################################################
-- tipo_documento
-- ##############################################################
CREATE TABLE sicar.tipo_documento
(
  tipo_documento NUMERIC(01) NOT NULL,
  descricao      VARCHAR(40) NOT NULL, -- Nome de apresentação do tipo

  CONSTRAINT tipo_documento_pkey PRIMARY KEY (tipo_documento)
);

INSERT INTO sicar.tipo_documento VALUES (0, 'CNPJ');
INSERT INTO sicar.tipo_documento VALUES (1, 'CPF');
-- ##############################################################
-- pessoa
-- ##############################################################
CREATE TABLE sicar.pessoa
(
  pessoa         NUMERIC(07)  NOT NULL,
  tipo_documento NUMERIC(01) NOT NULL,
  documento      VARCHAR(11)  NOT NULL,
  nome           VARCHAR(40)  NOT NULL,
  sobrenome      VARCHAR(100) ,
  email          VARCHAR(100) NOT NULL,

  CONSTRAINT pessoa_un_email UNIQUE (email),

  CONSTRAINT pessoa_pkey PRIMARY KEY (pessoa),


  CONSTRAINT pessoa_fk_tipo_documento FOREIGN KEY (tipo_documento)
  REFERENCES sicar.tipo_documento (tipo_documento) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- Trigger Function
INSERT INTO sicar.sequencia VALUES (0, 0, 1, 1, 'Pessoa ID');
/*
CREATE OR REPLACE FUNCTION sicar.trf_pessoa_id()
  RETURNS trigger AS
$BODY$BEGIN

  NEW.pessoa := (SELECT sicar.f_seq_nextval(0));

  RETURN NEW;
END;$BODY$
LANGUAGE plpgsql;

-- Trigger

CREATE TRIGGER "TRG_PESSOA_01"
BEFORE INSERT
ON sicar.pessoa
FOR EACH ROW
EXECUTE PROCEDURE sicar.trf_pessoa_id();*/
-- ##############################################################
-- familia
-- ##############################################################
CREATE TABLE sicar.familia
(
  familia   NUMERIC(06) NOT NULL,
  cabeca    NUMERIC(07) NOT NULL,
  nome      VARCHAR(20) NOT NULL,
  sobrenome VARCHAR(40),

  CONSTRAINT familia_pkey PRIMARY KEY (familia)
);

-- Trigger Function
INSERT INTO sicar.sequencia VALUES (5, 0, 1, 1, 'Familia ID');
/*
CREATE OR REPLACE FUNCTION sicar.trf_familia_id()
  RETURNS trigger AS
$BODY$BEGIN

  NEW.familia := (SELECT sicar.f_seq_nextval(5));

  RETURN NEW;
END;$BODY$
LANGUAGE plpgsql;

-- Trigger
CREATE TRIGGER "TRG_FAMILIA_01"
BEFORE INSERT
ON sicar.familia
FOR EACH ROW
EXECUTE PROCEDURE sicar.trf_familia_id();*/
-- ##############################################################
-- familia_membro
-- ##############################################################
CREATE TABLE sicar.familia_membro
(
  familia NUMERIC(06) NOT NULL,
  pessoa  NUMERIC(07) NOT NULL,

  CONSTRAINT familia_membro_pkey PRIMARY KEY (familia, pessoa),

  CONSTRAINT familia_membro_fk_familia FOREIGN KEY (familia)
  REFERENCES sicar.familia (familia) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION,

  CONSTRAINT familia_membro_fk_pessoa FOREIGN KEY (pessoa)
  REFERENCES sicar.pessoa (pessoa) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- ##############################################################
-- tipo_conta
-- ##############################################################
CREATE TABLE sicar.tipo_conta
(
  tipo_conta NUMERIC(02) NOT NULL,
  nome       VARCHAR(40) NOT NULL, -- Nome de apresentação do tipo

  CONSTRAINT tipo_conta_pkey PRIMARY KEY (tipo_conta)
);

INSERT INTO sicar.tipo_conta VALUES (0, 'Corrente');
INSERT INTO sicar.tipo_conta VALUES (1, 'Salário');
INSERT INTO sicar.tipo_conta VALUES (2, 'Poupança');
INSERT INTO sicar.tipo_conta VALUES (3, 'Investimento');
-- ##############################################################
-- conta
-- ##############################################################
CREATE TABLE sicar.conta
(
  conta                NUMERIC(12)   NOT NULL,
  tipo_conta           NUMERIC(02)   NOT NULL, -- Tipo de conta
  titular              NUMERIC(07)   NOT NULL, -- Código de identificação do titular da conta
  nome                 VARCHAR(40)   NOT NULL, -- Nome de apresentação da conta
  saldo                NUMERIC(12,2) NOT NULL, -- Saldo atual da conta
  saldo_final_previsto NUMERIC(12,2) NOT NULL, -- Saldo esperado para o final do mês
  
  CONSTRAINT conta_pkey PRIMARY KEY (conta),

  CONSTRAINT conta_fk_tipo_conta FOREIGN KEY (tipo_conta)
  REFERENCES sicar.tipo_conta (tipo_conta) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX conta_idx_titular ON sicar.conta (titular);

-- Trigger Function
INSERT INTO sicar.sequencia VALUES (1, 0, 1, 1, 'Conta ID');
/*
CREATE OR REPLACE FUNCTION sicar.trf_conta_id()
  RETURNS trigger AS
$BODY$BEGIN

  NEW.conta := (SELECT sicar.f_seq_nextval(1));

  RETURN NEW;
END;$BODY$
LANGUAGE plpgsql;

-- Trigger
CREATE TRIGGER "TRG_CONTA_01"
BEFORE INSERT
ON sicar.conta
FOR EACH ROW
EXECUTE PROCEDURE sicar.trf_conta_id();*/
-- ##############################################################
-- conta_saldo
-- ##############################################################
CREATE TABLE sicar.conta_saldo
(
  conta          NUMERIC(12,0)  NOT NULL, -- Conta 
  periodo        NUMERIC(6,0)   NOT NULL, -- Período (ano/mes)
  saldo_inicial  NUMERIC(12,2)  NOT NULL, -- Saldo de fechamento do período anterior
  receita        NUMERIC(12,2)  NOT NULL, -- Valor total da receitas
  transf_entrada NUMERIC(12,2)  NOT NULL, -- Valor total de Transferências recebidas
  transf_saida   NUMERIC(12,2)  NOT NULL, -- Valor total de Transferências realizadas
  investimento   NUMERIC(12,2)  NOT NULL, -- Valor total de investimento
  d_fixa         NUMERIC(12,2)  NOT NULL, -- Valor total de despesas fixas
  d_variavel     NUMERIC(12,2)  NOT NULL, -- Valor total de depesas variáveis
  d_adicional    NUMERIC(12,2)  NOT NULL, -- Valor total de depesas adicionais
  d_extra        NUMERIC(12,2)  NOT NULL, -- Valor total de despesas extraordinárias
  saldo_final    NUMERIC(12,2)  NOT NULL, -- Saldo de fechamento do periodo

  CONSTRAINT conta_saldo_pkey PRIMARY KEY (conta, periodo),

  CONSTRAINT conta_saldo_fk_conta FOREIGN KEY (conta)
  REFERENCES sicar.conta (conta) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- ##############################################################
-- cartao
-- ##############################################################
CREATE TABLE sicar.cartao
(
  cartao   NUMERIC(12)   NOT NULL,
  conta    NUMERIC(12)   NOT NULL, -- Conta onde o cartão foi tirado
  portador NUMERIC(07)   NOT NULL, -- Portador do cartão
  nome     VARCHAR(30)   NOT NULL, -- Nome para apresentação
  saldo    NUMERIC(12,2) NOT NULL, -- Saldo atual do cartão

  CONSTRAINT cartao_pkey PRIMARY KEY (cartao),

  CONSTRAINT cartao_fk_conta FOREIGN KEY (conta)
  REFERENCES sicar.conta (conta) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION,

  CONSTRAINT cartao_fk_pessoa FOREIGN KEY (portador)
  REFERENCES sicar.pessoa (pessoa) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- Trigger Function
INSERT INTO sicar.sequencia VALUES (4, 0, 1, 1, 'Cartao ID');
/*
CREATE OR REPLACE FUNCTION sicar.trf_cartao_id()
  RETURNS trigger AS
$BODY$BEGIN

  NEW.cartao := (SELECT sicar.f_seq_nextval(4));

  RETURN NEW;
END;$BODY$
LANGUAGE plpgsql;

-- Trigger
CREATE TRIGGER "TRG_CARTAO_01"
BEFORE INSERT
ON sicar.cartao
FOR EACH ROW
EXECUTE PROCEDURE sicar.trf_cartao_id();*/
-- ##############################################################
-- movimento
-- ##############################################################
CREATE TABLE sicar.movimento
(
  movimento       NUMERIC(15)    NOT NULL, -- Código de identificação
  conta           NUMERIC(12)    NOT NULL, -- Conta onde o movimento ocorreu
  cartao          NUMERIC(12),             -- Caso exista indica que é um movimento de cartão
  periodo         NUMERIC(06)    NOT NULL, -- Indica o periodo em que o movimento foi gerado (descasado da data do movimento)
  data_movimento  DATE           NOT NULL, -- Data da compra
  data_liquidacao DATE           NOT NULL, -- Data do pagamento
  operacao        NUMERIC(01)    NOT NULL, -- Indicador de operação (Cr/Db)
  categoria       NUMERIC(12)    NOT NULL, -- Categoria do movimento (implica em conceito)
  parcela         NUMERIC(03)    NOT NULL, -- Parcela atual do movimento (ex: 3 de 7)
  qtd_parcela     NUMERIC(03)    NOT NULL, -- Quantidade de parcelas da compra
  valor           NUMERIC(12,2)  NOT NULL, -- Valor total do movimento (se parcelado valor da parcela)
  valor_total     NUMERIC(12,2),           -- Valor total da compra
  descricao       VARCHAR(40)    NOT NULL, -- Alguma descrição imputada pelo usuário
  anotacao        VARCHAR(100),            -- Alguma anotação adicional

  CONSTRAINT movimento_pkey PRIMARY KEY (movimento),

  CONSTRAINT movimento_fk_categoria FOREIGN KEY (categoria)
  REFERENCES sicar.categoria (categoria) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION,

  CONSTRAINT movimento_fk_conta FOREIGN KEY (conta)
  REFERENCES sicar.conta (conta) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION,

  CONSTRAINT movimento_fk_operacao FOREIGN KEY (operacao)
  REFERENCES sicar.operacao (operacao) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- Trigger Function
INSERT INTO sicar.sequencia VALUES (2, 0, 1, 1, 'Movimento ID');
/*
CREATE OR REPLACE FUNCTION sicar.trf_movimento_id()
  RETURNS trigger AS
$BODY$BEGIN

  NEW.movimento := to_char(now(), 'YYDDD') || '' || lpad((SELECT sicar.f_seq_nextval(2)::text), 9, '0');

  RETURN NEW;
END;$BODY$
LANGUAGE plpgsql;

-- Trigger
CREATE TRIGGER "TRG_MOVIMENTO_01"
BEFORE INSERT
ON sicar.movimento
FOR EACH ROW
EXECUTE PROCEDURE sicar.trf_movimento_id();*/
-- ##############################################################
-- movimento_pessoa
-- ##############################################################
CREATE TABLE sicar.movimento_pessoa
(
   movimento NUMERIC(15) NOT NULL, -- Movimento que foi realizado
   pessoa    NUMERIC(07) NOT NULL, -- Pessoa com quem o movimento foi realizado

  CONSTRAINT movimento_pessoa_pkey PRIMARY KEY (movimento, pessoa),

  CONSTRAINT movimento_fk_movimento FOREIGN KEY (movimento)
  REFERENCES sicar.movimento (movimento) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION,

  CONSTRAINT movimento_fk_pessoa FOREIGN KEY (pessoa)
  REFERENCES sicar.pessoa (pessoa) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- ##############################################################
-- usuario
-- ##############################################################
CREATE TABLE sicar.usuario
(
   usuario       NUMERIC(07) NOT NULL, -- Código de identificação do usuário
   pessoa        NUMERIC(07) NOT NULL, -- Cadastro da pessoa que é o usuário
   senha         VARCHAR(8) NOT NULL,
   ultimo_acesso DATE,                 -- Data do último acesso ao sistema
   
  CONSTRAINT usuario_pkey PRIMARY KEY (usuario),

  CONSTRAINT usuario_un_pessoa UNIQUE (pessoa),
  
  CONSTRAINT usuario_fk_pessoa FOREIGN KEY (pessoa)
  REFERENCES sicar.pessoa (pessoa) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- Trigger Function
INSERT INTO sicar.sequencia VALUES (6, 0, 1, 1, 'Usuario ID');
/*
CREATE OR REPLACE FUNCTION sicar.trf_usuario_id()
  RETURNS trigger AS
$BODY$BEGIN

  NEW.usuario := (SELECT sicar.f_seq_nextval(6));

  RETURN NEW;
END;$BODY$
LANGUAGE plpgsql;

-- Trigger
CREATE TRIGGER "TRG_USUARIO_01"
BEFORE INSERT
ON sicar.usuario
FOR EACH ROW
EXECUTE PROCEDURE sicar.trf_usuario_id();*/
