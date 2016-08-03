package br.com.bsparaujo.sicar.datatype;

import lombok.AccessLevel;
import lombok.EqualsAndHashCode;
import lombok.Getter;

import java.time.LocalDate;
import java.time.Month;
import java.time.Year;

@EqualsAndHashCode
@Getter(AccessLevel.PUBLIC)
public final class Periodo {
    private final Year ano;
    private final Month mes;

    private Periodo(final int ano, final int mes) {
        if (mes > 12 | mes < 1) {
            throw new PeriodoException("O mês deve ser entre 1 e 12");
        }

        if (ano <= 0) {
            throw new PeriodoException("O ano deve ser maior que zero.");
        }

        this.ano = Year.of(ano);
        this.mes = Month.of(mes);
    }

    /**
     * Constroi um período com o Ano e Mês informados.
     * @param ano Ano desejado
     * @param mes Mês desejado
     * @return O período construído
     */
    public static Periodo of(final int ano, final int mes) {
        return new Periodo(ano, mes);
    }

    /**
     * Otém o período corrente segundo o relógio do Sistema Operacional.
     *
     * @see #anterior()
     * @see #seguinte()
     *
     * @return Período corrente
     */
    public static Periodo corrente() {
        final LocalDate now = LocalDate.now();
        return of (now.getYear(), now.getMonthValue());
    }

    /**
     * Verifica se o período em questão é posterior ao periodo informado.
     *
     * @param periodo Periodo a ser comparado
     * @see #corrente()
     * @see #anterior()
     * @see #seguinte()
     * @see #anterior(Periodo)
     * @return <code>true</code> se o periodo for posterior ao período comparado, <code>false</code> caso contrário
     */
    public boolean posterior(Periodo periodo) {
        return ano.isAfter(periodo.ano) || mes.getValue() > periodo.mes.getValue();
    }

    /**
     * Verifica se o período em questão é anterior ao periodo informado.
     *
     * @param periodo Periodo a ser comparado
     * @see #corrente()
     * @see #anterior()
     * @see #seguinte()
     * @see #posterior(Periodo)
     * @return <code>true</code> se o periodo for anterior ao período comparado, <code>false</code> caso contrário
     */
    public boolean anterior(Periodo periodo) {
        return ano.isBefore(periodo.ano) || mes.getValue() < periodo.mes.getValue();
    }

    /**
     * Obtém o período seguinte ao corrente.
     *
     * @see #corrente()
     * @see #anterior()
     * @see #anterior(Periodo)
     * @see #posterior(Periodo)
     */
    public Periodo seguinte() {
        final Month month = mes.plus(1);
        final Year year = mes.getValue() == 12 ? ano.plusYears(1) : ano;

        return of(year.getValue(), month.getValue());
    }

    /**
     * Obtém o período anterior ao corrente.
     *
     * @see #corrente()
     * @see #seguinte()
     * @see #anterior(Periodo)
     * @see #posterior(Periodo)
     */
    public Periodo anterior() {
        final Month month = mes.minus(1);
        final Year year = mes.getValue() == 12 ? ano.minusYears(1) : ano;

        return of(year.getValue(), month.getValue());
    }

    /**
     * Identifica se este período está no passado em relação ao {@link #corrente()}.
     *
     * @return <code>true</code> se estiver no passado, <code>false</code> caso contrário
     */
    public boolean estaNoPassado() {
        return anterior(Periodo.corrente());
    }

    /**
     * Identifica se este período está no futuro em relação ao {@link #corrente()}.
     *
     * @return <code>true</code> se estiver no futuro, <code>false</code> caso contrário
     */
    public boolean estaNoFuturo() {
        return posterior(Periodo.corrente());
    }

    /**
     * Identifica se este período está no presente em relação ao {@link #corrente()}.
     *
     * @return <code>true</code> se estiver no presente, <code>false</code> caso contrário
     */
    public boolean estaNoPresente() {
        final Periodo corrente = Periodo.corrente();
        return !anterior(corrente) && !posterior(corrente);
    }
}
