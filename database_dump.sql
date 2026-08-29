-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: cl204214
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `pi_bloco`
--

DROP TABLE IF EXISTS `pi_bloco`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pi_bloco` (
  `id_anotacao` int(11) NOT NULL AUTO_INCREMENT,
  `conteudo` text NOT NULL,
  `cor_nota` varchar(50) DEFAULT '0xfff4f1eb',
  `favorito` varchar(10) DEFAULT 'false',
  `id_usuario` int(11) NOT NULL,
  PRIMARY KEY (`id_anotacao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pi_bloco`
--

LOCK TABLES `pi_bloco` WRITE;
/*!40000 ALTER TABLE `pi_bloco` DISABLE KEYS */;
/*!40000 ALTER TABLE `pi_bloco` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pi_cronograma`
--

DROP TABLE IF EXISTS `pi_cronograma`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pi_cronograma` (
  `id_cronograma` int(11) NOT NULL AUTO_INCREMENT,
  `id_materia` int(11) NOT NULL,
  `dia_semana` varchar(50) NOT NULL,
  `hora_inicio` varchar(50) NOT NULL,
  `hora_final` varchar(50) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  PRIMARY KEY (`id_cronograma`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pi_cronograma`
--

LOCK TABLES `pi_cronograma` WRITE;
/*!40000 ALTER TABLE `pi_cronograma` DISABLE KEYS */;
/*!40000 ALTER TABLE `pi_cronograma` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pi_eventos`
--

DROP TABLE IF EXISTS `pi_eventos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pi_eventos` (
  `id_evento` int(11) NOT NULL AUTO_INCREMENT,
  `tipo` varchar(500) NOT NULL,
  `data` varchar(50) NOT NULL,
  `cor` varchar(50) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  PRIMARY KEY (`id_evento`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pi_eventos`
--

LOCK TABLES `pi_eventos` WRITE;
/*!40000 ALTER TABLE `pi_eventos` DISABLE KEYS */;
INSERT INTO `pi_eventos` VALUES (1,'lava cabelo','2026-06-15','0xff00bf63',1),(2,'lavar cabelo','2026-06-14','0xffff5f00',3),(3,'prova fisica','2026-06-17','0xffd203a4',4);
/*!40000 ALTER TABLE `pi_eventos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pi_flash`
--

DROP TABLE IF EXISTS `pi_flash`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pi_flash` (
  `id_flash` int(11) NOT NULL AUTO_INCREMENT,
  `id_materia` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `pergunta` text NOT NULL,
  `tema` varchar(200) NOT NULL,
  `resposta` text NOT NULL,
  PRIMARY KEY (`id_flash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pi_flash`
--

LOCK TABLES `pi_flash` WRITE;
/*!40000 ALTER TABLE `pi_flash` DISABLE KEYS */;
/*!40000 ALTER TABLE `pi_flash` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pi_inteligencias`
--

DROP TABLE IF EXISTS `pi_inteligencias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pi_inteligencias` (
  `id_tipo` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `metodo` text NOT NULL,
  `cor` varchar(50) NOT NULL,
  PRIMARY KEY (`id_tipo`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pi_inteligencias`
--

LOCK TABLES `pi_inteligencias` WRITE;
/*!40000 ALTER TABLE `pi_inteligencias` DISABLE KEYS */;
INSERT INTO `pi_inteligencias` VALUES (1,'Lógico-matemática','[\"Organize os estudos em passos cronometrados e lógicos.\",\"Use raciocínio de causa e efeito para fixar ideias.\",\"Resolva problemas e crie pequenos testes práticos com frequência.\"]','#ffbd59'),(2,'Linguística','[\"Escreva resumos explicativos em suas próprias palavras.\",\"Leia em voz alta ou grave áudios ensinando a matéria.\",\"Utilize flashcards textuais e debates sobre temas estudados.\"]','#9f042c'),(3,'Corporal','[\"Faça pausas ativas (ex: alongamentos, polichinelos).\",\"Use gestos ou caminhe enquanto repassa informações na mente.\",\"Utilize cartões de memorização físicos ou desenhe mapas no chão.\"]','#00bf63'),(4,'Espacial','[\"Construa mapas mentais coloridos, infográficos e esquemas.\",\"Use marcadores de texto em código de cores específicas.\",\"Associe conceitos complexos com símbolos visuais ou desenhos.\"]','#d203a4'),(5,'Interpessoal','[\"Estude em dupla ou monte grupos de discussão online.\",\"Explique a matéria para um colega ou familiar (estudo ativo).\",\"Participe de fóruns e responda dúvidas de outras pessoas.\"]','#ff5f00'),(6,'Musical','[\"Estude ouvindo sons instrumentais neutros ou ruído marrom.\",\"Crie rimas, paródias ou associações sonoras para memorização.\",\"Estude com batidas rítmicas de fundo para aumentar o foco.\"]','#8a03d2'),(7,'Intrapessoal','[\"Faça autoavaliações ao final de cada dia.\",\"Defina metas de estudos estritas e diários reflexivos.\",\"Estude em ambientes silenciosos onde consiga escutar seus próprios pensamentos.\"]','#5170ff');
/*!40000 ALTER TABLE `pi_inteligencias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pi_materia`
--

DROP TABLE IF EXISTS `pi_materia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pi_materia` (
  `id_materia` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `cor` varchar(100) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `ativo` int(11) DEFAULT 1,
  PRIMARY KEY (`id_materia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pi_materia`
--

LOCK TABLES `pi_materia` WRITE;
/*!40000 ALTER TABLE `pi_materia` DISABLE KEYS */;
/*!40000 ALTER TABLE `pi_materia` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pi_sessaoestudo`
--

DROP TABLE IF EXISTS `pi_sessaoestudo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pi_sessaoestudo` (
  `id_cron` int(11) NOT NULL AUTO_INCREMENT,
  `tempo_cronometro` int(11) NOT NULL,
  `descricao` varchar(500) DEFAULT '',
  `id_usuario` int(11) NOT NULL,
  `id_materia` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id_cron`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pi_sessaoestudo`
--

LOCK TABLES `pi_sessaoestudo` WRITE;
/*!40000 ALTER TABLE `pi_sessaoestudo` DISABLE KEYS */;
/*!40000 ALTER TABLE `pi_sessaoestudo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pi_tarefas`
--

DROP TABLE IF EXISTS `pi_tarefas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pi_tarefas` (
  `id_tarefa` int(11) NOT NULL AUTO_INCREMENT,
  `nome_tarefa` varchar(500) NOT NULL,
  `dificuldade` varchar(50) NOT NULL,
  `prazo` varchar(50) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `ativo` int(11) DEFAULT 1,
  PRIMARY KEY (`id_tarefa`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pi_tarefas`
--

LOCK TABLES `pi_tarefas` WRITE;
/*!40000 ALTER TABLE `pi_tarefas` DISABLE KEYS */;
INSERT INTO `pi_tarefas` VALUES (1,'terminar lista de fisica','Média','2026-06-14',2,1),(2,'lista geografia','Média','',2,1),(3,'oii tarefa','Média','',4,1);
/*!40000 ALTER TABLE `pi_tarefas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pi_usuario`
--

DROP TABLE IF EXISTS `pi_usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pi_usuario` (
  `id_usuario` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `senha` varchar(100) NOT NULL,
  `ativo` int(11) DEFAULT 1,
  `foto` longtext DEFAULT NULL,
  `plano` varchar(50) DEFAULT 'Gratuito',
  `tipo_dom` varchar(100) DEFAULT '',
  `clas_inteli` varchar(100) DEFAULT '',
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pi_usuario`
--

LOCK TABLES `pi_usuario` WRITE;
/*!40000 ALTER TABLE `pi_usuario` DISABLE KEYS */;
INSERT INTO `pi_usuario` VALUES (1,'ju','julinhazinha@gmail','$2y$10$mPpFrxFLfpv3kSr2sZN9o.TDW2DD7/3TQzzi3FtSyVI7q.PFOY4hi',1,'','Gratuito','Corporal','[]'),(2,'juzinha','jujubas@gmail','$2y$10$Rjc0XuWx7sUZw4AXF99U2.uybaPqVpxd9Dfi/joOwHJj3JwHWAC0C',1,'','Gratuito','Espacial','\"0xffd203a4\"'),(3,'julis','jubinha@gmail.com','$2y$10$c0CycCx7ygF4XBDzR9teMeE7LNg7CeGePYrqP0h.J0FhuG1gXMwk2',1,'blob:http://localhost:55949/89c371ed-e2d3-464b-9d43-6207c6feea9c','Gratuito','Interpessoal','\"0xffff5f00\"'),(4,'ju','linha@gmail','$2y$10$p1Fql7JAQ1yQv8C0UgMtuevIg7m/OFMwFfBP9wTqyCLfv5HnJz5.6',1,'blob:http://localhost:58334/59d167bd-482a-430a-b1fa-93349eaf90e8','Gratuito','Espacial','[\"Espacial\",\"Interpessoal\",\"Corporal\"]');
/*!40000 ALTER TABLE `pi_usuario` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-14 21:09:02
