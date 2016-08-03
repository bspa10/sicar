package br.com.bsparaujo.datatype;

import javax.swing.text.MaskFormatter;
import java.text.ParseException;
import java.util.InputMismatchException;

public enum TipoDocumento {

    CPF (1){
        @Override
        String formatar(Documento documento) {
            try {
                return formatar(CPF_MASCARA, documento.semFormato());
            } catch (ParseException e) {
                throw new RuntimeException();
            }
        }

        @Override
        boolean ehValido(final String documento) {
            // considera-se erro CPF's formados por uma sequencia de numeros iguais
            if (documento == null || documento.length() != 11 || documento.matches(CPF_REGEX)) {
                return false;
            }

            int sm, i, r, num, peso;

            // "try" - protege o codigo para eventuais erros de conversao de tipo (int)
            try {
                // Calculo do 1ro digito Verificador
                sm = 0;
                peso = 10;
                for (i = 0; i < 9; i++) {
                    // converte o i-esimo caractere do CPF em um numero:
                    // por exemplo, transforma o caractere '0' no inteiro 0
                    // (48 eh a posicao de '0' na tabela ASCII)
                    num = documento.charAt(i) - 48;
                    sm = sm + (num * peso);
                    peso = peso - 1;
                }

                r = 11 - (sm % 11);
                final char dig10 = (r == 10) || (r == 11) ? '0' : (char)(r + 48);

                // Calculo do 2do digito Verificador
                sm = 0;
                peso = 11;
                for(i = 0; i < 10; i++) {
                    num = documento.charAt(i) - 48;
                    sm = sm + (num * peso);
                    peso = peso - 1;
                }

                r = 11 - (sm % 11);
                final char dig11 = (r == 10) || (r == 11) ? '0' : (char)(r + 48);

                // Verifica se os digitos calculados conferem com os digitos informados.
                return (dig10 == documento.charAt(9)) && (dig11 == documento.charAt(10));
            } catch (InputMismatchException erro) {
                return false;

            }
        }
    },

    CNPJ (0) {
        @Override
        String formatar(Documento documento) {
            try {
                return formatar(CNPJ_MASCARA, documento.semFormato());
            } catch (ParseException e) {
                throw new RuntimeException();
            }
        }

        @Override
        boolean ehValido(String documento) {
            // considera-se erro CNPJ's formados por uma sequencia de numeros iguais
            if (documento == null || documento.length() != 14 || documento.matches(CNPJ_REGEX)) {
                return false;
            }

            int sm, i, r, num, peso;

            // "try" - protege o código para eventuais erros de conversao de tipo (int)
            try {
                // Calculo do 1ro digito Verificador
                sm = 0;
                peso = 2;
                for (i = 11; i >= 0; i--) {
                    // converte o i-ésimo caractere do CNPJ em um número:
                    // por exemplo, transforma o caractere '0' no inteiro 0
                    // (48 eh a posição de '0' na tabela ASCII)
                    num = documento.charAt(i) - 48;
                    sm = sm + (num * peso);
                    peso = peso + 1;
                    if (peso == 10) {
                        peso = 2;
                    }
                }

                r = sm % 11;
                char dig13 = (r == 0) || (r == 1) ? '0' : (char)((11-r) + 48);

                // Calculo do 2do digito Verificador
                sm = 0;
                peso = 2;
                for (i = 12; i >= 0; i--) {
                    num = documento.charAt(i) - 48;
                    sm = sm + (num * peso);
                    peso = peso + 1;
                    if (peso == 10) {
                        peso = 2;
                    }
                }

                r = sm % 11;
                char dig14 = (r == 0) || (r == 1) ? '0' : (char)((11-r) + 48);

                // Verifica se os dígitos calculados conferem com os dígitos informados.
                return (dig13 == documento.charAt(12)) && (dig14 == documento.charAt(13));
            } catch (InputMismatchException erro) {
                return false;
            }
        }
    };

    private static final String CPF_MASCARA = "###.###.###-##";
    private static final String CPF_REGEX = "^(0{11}|1{11}|2{11}|3{11}|4{11}|5{11}|6{11}|7{11}|9{11}|9{11})$";

    private static final String CNPJ_MASCARA = "##.###.###/####-##";
    private static final String CNPJ_REGEX = "^(0{14}|1{14}|2{14}|3{14}|4{14}|5{14}|6{14}|7{14}|8{14}|9{14})$";

    private final Integer id;

    TipoDocumento(Integer id) {
        this.id = id;
    }

    /**
     * Obtém o código do enumerador.
     */
    public Integer value() {
        return id;
    }

    /**
     * Formata o documento para apresentação.
     *
     * @param documento Documento que será formatado
     * @return String com o documento formatado
     */
    abstract String formatar(final Documento documento);

    /**
     * Identifica se o documento passado está no formato correto
     * @param documento Documento que será verificado
     * @return <code>true</code> se o documento for válido, <code>false</code> caso contrário
     */
    abstract boolean ehValido(final String documento);

    /**
     * Obtém o tipo de documento do id passado.
     *
     * @param id Identificação do tipo de documento
     * @return Tipo de documento, ou null caso o tipo não exista
     */
    public static TipoDocumento valueOf(Integer id) {
        switch (id) {
            case 0: return CNPJ;
            case 1: return CPF;
        }

        return null;
    }

    String formatar(final String mascara, final String texto) throws ParseException {
        final MaskFormatter mf = new MaskFormatter(mascara);
        mf.setValueContainsLiteralCharacters(false);
        return mf.valueToString(texto);
    }
}
