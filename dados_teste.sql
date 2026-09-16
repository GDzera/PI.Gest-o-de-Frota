-- =========================================================
-- Dados fictícios para teste da Plataforma de Gestão de Frota
-- Rode este script DEPOIS do schema.sql, no mesmo banco (frota_db)
-- =========================================================
USE frota_db;

-- ---------------------------------------------------------
-- Veículos
-- ---------------------------------------------------------
INSERT INTO veiculos (codigo_frota, placa, marca, modelo, ano, km_atual, km_ultima_manutencao, intervalo_manutencao, km_proxima_manutencao, status) VALUES
('45102', 'ABC1D23', 'Fiat', 'Strada', 2022, 58500, 58500, 10000, 68500, 'ativo'),
('45103', 'DEF4G56', 'Volkswagen', 'Saveiro', 2021, 70800, 60000, 10000, 70000, 'ativo'),
('45104', 'HIJ7K89', 'Chevrolet', 'S10', 2023, 15000, 10000, 10000, 20000, 'ativo');

-- ---------------------------------------------------------
-- Oficina extra (já existe "Oficina Central" vinda do schema.sql)
-- ---------------------------------------------------------
INSERT INTO oficinas (nome, endereco, telefone, tipo_servico) VALUES
('Auto Center Rápido', 'Av. das Nações, 500 - Centro', '(14) 98888-1234', 'Funilaria e mecânica geral');

-- ---------------------------------------------------------
-- Condutores (login + vínculo com veículo)
-- Senha de todos: 123456
-- ---------------------------------------------------------
INSERT INTO usuarios (nome, email, senha, perfil) VALUES
('João da Silva',  'joao@teste.com',   '$2y$10$rgdPiHsGE0wAzgDsvL7etOsWMnyqcQT9hRjG1QwNfit7IDrK.JE8e', 'condutor'),
('Carlos Souza',   'carlos@teste.com', '$2y$10$rgdPiHsGE0wAzgDsvL7etOsWMnyqcQT9hRjG1QwNfit7IDrK.JE8e', 'condutor'),
('Marcos Lima',    'marcos@teste.com', '$2y$10$rgdPiHsGE0wAzgDsvL7etOsWMnyqcQT9hRjG1QwNfit7IDrK.JE8e', 'condutor');

INSERT INTO condutores (usuario_id, cpf_matricula, telefone)
SELECT id, '111.111.111-11', '(14) 99999-0001' FROM usuarios WHERE email = 'joao@teste.com';
INSERT INTO condutores (usuario_id, cpf_matricula, telefone)
SELECT id, '222.222.222-22', '(14) 99999-0002' FROM usuarios WHERE email = 'carlos@teste.com';
INSERT INTO condutores (usuario_id, cpf_matricula, telefone)
SELECT id, '333.333.333-33', '(14) 99999-0003' FROM usuarios WHERE email = 'marcos@teste.com';

-- Vincula cada condutor ao seu veículo
UPDATE veiculos v JOIN condutores c ON c.cpf_matricula = '111.111.111-11' SET v.condutor_id = c.id WHERE v.codigo_frota = '45102';
UPDATE veiculos v JOIN condutores c ON c.cpf_matricula = '222.222.222-22' SET v.condutor_id = c.id WHERE v.codigo_frota = '45103';
UPDATE veiculos v JOIN condutores c ON c.cpf_matricula = '333.333.333-33' SET v.condutor_id = c.id WHERE v.codigo_frota = '45104';

-- ---------------------------------------------------------
-- Registro de quilometragem (para os gráficos de histórico funcionarem)
-- ---------------------------------------------------------
INSERT INTO registro_km (veiculo_id, km, origem, registrado_em)
SELECT id, 55000, 'ajuste_manual', DATE_SUB(NOW(), INTERVAL 30 DAY) FROM veiculos WHERE codigo_frota = '45102';
INSERT INTO registro_km (veiculo_id, km, origem, registrado_em)
SELECT id, 58500, 'ajuste_manual', NOW() FROM veiculos WHERE codigo_frota = '45102';

INSERT INTO registro_km (veiculo_id, km, origem, registrado_em)
SELECT id, 65000, 'ajuste_manual', DATE_SUB(NOW(), INTERVAL 30 DAY) FROM veiculos WHERE codigo_frota = '45103';
INSERT INTO registro_km (veiculo_id, km, origem, registrado_em)
SELECT id, 70800, 'ajuste_manual', NOW() FROM veiculos WHERE codigo_frota = '45103';

INSERT INTO registro_km (veiculo_id, km, origem, registrado_em)
SELECT id, 12000, 'ajuste_manual', DATE_SUB(NOW(), INTERVAL 30 DAY) FROM veiculos WHERE codigo_frota = '45104';
INSERT INTO registro_km (veiculo_id, km, origem, registrado_em)
SELECT id, 15000, 'ajuste_manual', NOW() FROM veiculos WHERE codigo_frota = '45104';

-- ---------------------------------------------------------
-- Solicitações de manutenção em status variados
-- ---------------------------------------------------------

-- 1) Aberta (aguardando o gestor analisar) - João, frota 45102
INSERT INTO solicitacoes (veiculo_id, condutor_id, km_informado, tipo, motivo, observacoes, status)
SELECT v.id, c.id, 58500, 'preventiva', 'Revisão dos 60.000 km', 'Carro começou a fazer um barulho leve no freio.', 'aberta'
FROM veiculos v JOIN condutores c ON c.cpf_matricula = '111.111.111-11'
WHERE v.codigo_frota = '45102';

-- 2) Em análise - Carlos, frota 45103 (corretiva)
INSERT INTO solicitacoes (veiculo_id, condutor_id, km_informado, tipo, motivo, descricao_problema, status)
SELECT v.id, c.id, 70800, 'corretiva', 'Luz do motor acesa no painel', 'A luz de injeção eletrônica acendeu no painel durante a viagem e o carro perdeu um pouco de força.', 'em_analise'
FROM veiculos v JOIN condutores c ON c.cpf_matricula = '222.222.222-22'
WHERE v.codigo_frota = '45103';

-- 3) Concluída - Marcos, frota 45104 (com manutenção já registrada no histórico)
INSERT INTO solicitacoes (veiculo_id, condutor_id, km_informado, tipo, motivo, status, oficina_id)
SELECT v.id, c.id, 15000, 'preventiva', 'Troca de óleo programada', 'concluida', o.id
FROM veiculos v
JOIN condutores c ON c.cpf_matricula = '333.333.333-33'
JOIN oficinas o ON o.nome = 'Oficina Central'
WHERE v.codigo_frota = '45104';

INSERT INTO manutencoes (solicitacao_id, veiculo_id, data_manutencao, km_manutencao, tipo, servicos_realizados, oficina_id, valor, pecas_substituidas, proxima_manutencao_km)
SELECT s.id, v.id, DATE_SUB(CURDATE(), INTERVAL 10 DAY), 15000, 'preventiva', 'Troca de óleo e filtro de óleo', o.id, 280.00, 'Filtro de óleo', 25000
FROM solicitacoes s
JOIN veiculos v ON v.id = s.veiculo_id AND v.codigo_frota = '45104'
JOIN oficinas o ON o.nome = 'Oficina Central';
