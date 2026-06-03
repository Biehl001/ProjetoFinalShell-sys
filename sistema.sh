#!/bin/bash

# Sistema de Controle de Estoque
# Projeto Final - Shell Script

PASTA_PRODUTOS="Estoque/produtos"
PASTA_RELATORIOS="Estoque/relatorios"
PASTA_BACKUP="Estoque/backup"

# Contador para gerar ID dos produtos
gerar_id() {
    local ultimo=$(ls "$PASTA_PRODUTOS" 2>/dev/null | sort -n | tail -1 | sed 's/\.txt//')
    if [ -z "$ultimo" ]; then
        echo 1
    else
        echo $((ultimo + 1))
    fi
}

# 1 - Cadastrar produto
cadastrar_produto() {
    echo ""
    echo "===== CADASTRAR PRODUTO ====="
    read -p "Nome do produto: " nome
    read -p "Quantidade: " quantidade
    read -p "Valor: " valor
    read -p "Categoria: " categoria
    id=$(gerar_id)

    echo "Nome: $nome" > "$PASTA_PRODUTOS/$id.txt"
    echo "Quantidade: $quantidade" >> "$PASTA_PRODUTOS/$id.txt"
    echo "Valor: $valor" >> "$PASTA_PRODUTOS/$id.txt"
    echo "Categoria: $categoria" >> "$PASTA_PRODUTOS/$id.txt"

    echo ""
    echo "Produto #$id cadastrado com sucesso!"
}

# 2 - Pesquisar produto
pesquisar_produto() {
    echo ""
    echo "===== PESQUISAR PRODUTO ====="
    read -p "Digite o numero do produto: " id

    if [ -f "$PASTA_PRODUTOS/$id.txt" ]; then
        echo ""
        echo "--- Produto #$id ---"
        cat "$PASTA_PRODUTOS/$id.txt"
    else
        echo "Produto #$id nao encontrado."
    fi
}

# 3 - Atualizar estoque
atualizar_estoque() {
    echo ""
    echo "===== ATUALIZAR ESTOQUE ====="
    read -p "Digite o numero do produto: " id

    if [ -f "$PASTA_PRODUTOS/$id.txt" ]; then
        echo ""
        echo "--- Produto #$id ---"
        cat "$PASTA_PRODUTOS/$id.txt"
        echo ""
        read -p "Nova quantidade: " nova_qtd
        sed -i "s/Quantidade: .*/Quantidade: $nova_qtd/" "$PASTA_PRODUTOS/$id.txt"
        echo "Estoque atualizado com sucesso!"
    else
        echo "Produto #$id nao encontrado."
    fi
}

# 4 - Remover produto
remover_produto() {
    echo ""
    echo "===== REMOVER PRODUTO ====="
    read -p "Digite o numero do produto para remover: " id

    if [ -f "$PASTA_PRODUTOS/$id.txt" ]; then
        echo ""
        echo "--- Produto #$id ---"
        cat "$PASTA_PRODUTOS/$id.txt"
        echo ""
        read -p "Tem certeza? (s/n): " confirma
        if [ "$confirma" = "s" ]; then
            rm "$PASTA_PRODUTOS/$id.txt"
            echo "Produto #$id removido!"
        else
            echo "Operacao cancelada."
        fi
    else
        echo "Produto #$id nao encontrado."
    fi
}

# 5 - Relatorio
gerar_relatorio() {
    echo ""
    echo "===== RELATORIO DE ESTOQUE ====="

    total=0
    valor_total=0

    for arquivo in "$PASTA_PRODUTOS"/*.txt; do
        if [ -f "$arquivo" ]; then
            total=$((total + 1))
            id=$(basename "$arquivo" .txt)
            nome=$(grep "Nome:" "$arquivo" | cut -d' ' -f2-)
            qtd=$(grep "Quantidade:" "$arquivo" | cut -d' ' -f2)
            valor=$(grep "Valor:" "$arquivo" | cut -d' ' -f2)
            categoria=$(grep "Categoria:" "$arquivo" | cut -d' ' -f2-)

            echo "#$id | $nome | Qtd: $qtd | R$ $valor | $categoria"
        fi
    done

    if [ "$total" -eq 0 ]; then
        echo "Nenhum produto cadastrado."
    else
        echo ""
        echo "Total de produtos: $total"
    fi

    # Salvar relatorio em arquivo
    data_rel=$(date +%d-%m-%Y_%H-%M-%S)
    arquivo_rel="$PASTA_RELATORIOS/relatorio_$data_rel.txt"

    echo "Relatorio gerado em: $(date +%d/%m/%Y' '%H:%M:%S)" > "$arquivo_rel"
    echo "Total de produtos: $total" >> "$arquivo_rel"
    echo "" >> "$arquivo_rel"

    for arquivo in "$PASTA_PRODUTOS"/*.txt; do
        if [ -f "$arquivo" ]; then
            id=$(basename "$arquivo" .txt)
            echo "--- Produto #$id ---" >> "$arquivo_rel"
            cat "$arquivo" >> "$arquivo_rel"
            echo "" >> "$arquivo_rel"
        fi
    done

    echo "Relatorio salvo em: $arquivo_rel"
}

# 6 - Backup
fazer_backup() {
    echo ""
    cp "$PASTA_PRODUTOS"/*.txt "$PASTA_BACKUP/" 2>/dev/null
    echo "Backup realizado com sucesso em $PASTA_BACKUP/"
}

# Menu principal
while true; do
    echo ""
    echo "================================="
    echo "  SISTEMA DE CONTROLE DE ESTOQUE"
    echo "================================="
    echo "1 - Cadastrar produto"
    echo "2 - Pesquisar produto"
    echo "3 - Atualizar estoque"
    echo "4 - Remover produto"
    echo "5 - Relatorio"
    echo "6 - Backup"
    echo "0 - Sair"
    echo "================================="
    read -p "Escolha uma opcao: " opcao

    case $opcao in
        1) cadastrar_produto ;;
        2) pesquisar_produto ;;
        3) atualizar_estoque ;;
        4) remover_produto ;;
        5) gerar_relatorio ;;
        6) fazer_backup ;;
        0) echo "Saindo..."; exit 0 ;;
        *) echo "Opcao invalida!" ;;
    esac
done
