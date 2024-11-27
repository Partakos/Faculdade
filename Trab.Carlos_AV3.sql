-- Tabela para armazenar usuarios --
CREATE TABLE usuarios (
    usuario_id UUID PRIMARY KEY,
    nome TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    cpf TEXT NOT NULL UNIQUE,
    e_recrutador BOOLEAN NOT NULL DEFAULT FALSE,
    e_candidato BOOLEAN NOT NULL DEFAULT FALSE,
    e_empresa BOOLEAN NOT NULL DEFAULT FALSE, -- identifica se eh uma empresa --
    senha TEXT NOT NULL,
    biografia TEXT NULL,
    foto_perfil TEXT NULL,
    CONSTRAINT chk_papeis_usuario CHECK (
        (e_recrutador::int + e_candidato::int + e_empresa::int) = 1
    ) -- garante que o usuario seja apenas uma dessas opções --
);

-- Tabela para publicações --
CREATE TABLE publicacoes (
    publicacao_id UUID PRIMARY KEY,
    usuario_id UUID NOT NULL,
    conteudo TEXT NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE -- apaga as publicações se o usuário for deletado --
);

-- Tabela para conexões entre usuários (adicionando um amigo) --
CREATE TABLE conexoes (
    conexao_id UUID PRIMARY KEY,
    usuario1_id UUID NOT NULL,
    usuario2_id UUID NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pendente', 'aceito', 'rejeitado')),
    data_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (usuario1_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    FOREIGN KEY (usuario2_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE
);

-- Tabela para armazenar habilidades dos usuários --
CREATE TABLE habilidades (
    habilidade_id UUID PRIMARY KEY,
    usuario_id UUID NOT NULL,
    nome_habilidade TEXT NOT NULL,
    nivel_proficiencia TEXT NOT NULL CHECK (nivel_proficiencia IN ('iniciante', 'intermediario', 'avancado', 'expert')),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE
);

-- Tabela para mensagens privadas entre usuários --
CREATE TABLE mensagens (
    mensagem_id UUID PRIMARY KEY,
    remetente_id UUID NOT NULL,
    destinatario_id UUID NOT NULL,
    conteudo TEXT NOT NULL,
    data_envio TIMESTAMP NOT NULL DEFAULT NOW(),
    foi_lida BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (remetente_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    FOREIGN KEY (destinatario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE
);

-- Tabela para escolher as vagas --

CREATE TABLE vagas (
    vaga_id UUID PRIMARY KEY,
    empresa_id UUID NOT NULL, -- Relaciona a vaga com uma empresa
    titulo TEXT NOT NULL, -- Título da vaga
    descricao TEXT NOT NULL, -- Descrição da vaga
    localizacao TEXT NOT NULL, -- Localização (ex.: remoto, presencial)
    salario NUMERIC NULL, -- Salário, se aplicável
    data_criacao TIMESTAMP NOT NULL DEFAULT NOW(), -- Data de criação
    data_validade TIMESTAMP NULL, -- Data limite para a vaga
    FOREIGN KEY (empresa_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE -- Exclui as vagas se a empresa for excluída
);

-- Inserts corretos em usuarios --
INSERT INTO usuarios (usuario_id, nome, email, cpf, e_recrutador, e_candidato, e_empresa, senha)
VALUES (
    '123e4567-e89b-12d3-a456-426614174003',
    'TechCorp',
    'contato@techcorp.com',
    '11122233344', 
    FALSE, 
    FALSE, 
    TRUE,
    'senhaSegura123');

-- Insert em publicacoes --
INSERT INTO publicacoes (publicacao_id, usuario_id, conteudo)
VALUES 
(
    '456e7890-e89b-12d3-a456-426614174000',
    '123e4567-e89b-12d3-a456-426614174001',
    'Buscando oportunidades empolgantes na área de TI!'),
(
    '456e7890-e89b-12d3-a456-426614174001',
    '123e4567-e89b-12d3-a456-426614174000', 
    'Estamos contratando para diversas posições!');

-- Insert em conexoes --
INSERT INTO conexoes (conexao_id, usuario1_id, usuario2_id, status)
VALUES 
(
    '789e0123-e89b-12d3-a456-426614174000', 
    '123e4567-e89b-12d3-a456-426614174000',
    '123e4567-e89b-12d3-a456-426614174001', 
    'aceito');

-- Insert em habilidades --
INSERT INTO habilidades (habilidade_id, usuario_id, nome_habilidade, nivel_proficiencia)
VALUES 
(
    '890e1234-e89b-12d3-a456-426614174000', 
    '123e4567-e89b-12d3-a456-426614174001', 
    'Python', 
    'expert'),
(
    '890e1234-e89b-12d3-a456-426614174001', 
    '123e4567-e89b-12d3-a456-426614174001', 
    'Django', 
    'avancado');

-- Insert em mensagens --
INSERT INTO mensagens (mensagem_id, remetente_id, destinatario_id, conteudo)
VALUES 
(
    '901e2345-e89b-12d3-a456-426614174000', 
     '123e4567-e89b-12d3-a456-426614174001', 
    '123e4567-e89b-12d3-a456-426614174000', 
    'Oi, tenho interesse na vaga de desenvolvedor.');

INSERT INTO vagas (vaga_id, empresa_id, titulo, descricao, localizacao, salario, data_validade)
VALUES (
    '234e5678-e89b-12d3-a456-426614174004', 
    '123e4567-e89b-12d3-a456-426614174003', 
    'Desenvolvedor Full Stack', 
    'Trabalhar no desenvolvimento de soluções web.', 
    'Remoto', 
    8000.00, 
    '2024-12-31'
);


ALTER TABLE usuarios
ADD CONSTRAINT chk_cpf_format CHECK (cpf ~ '^\d{11}$');

ALTER TABLE publicacoes
ADD CONSTRAINT chk_conteudo_length CHECK (length(conteudo) > 0 AND length(conteudo) <= 5000);
