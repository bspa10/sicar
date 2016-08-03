package br.com.bsparaujo.sicar.datatype;

import org.junit.Assert;
import org.junit.Test;

import java.time.LocalDate;

public class PeriodoTest {

    @Test
    public void periodos_validos() {
        for (int i = 1; i <= 12; i++) {
            Periodo.of(1, i);
        }

        final LocalDate now = LocalDate.now();
        int ano = now.getYear();
        int mes = now.getMonthValue();

        final Periodo corrente = Periodo.corrente();
        Assert.assertNotNull(corrente);
        Assert.assertEquals(ano, corrente.ano().getValue());
        Assert.assertEquals(mes, corrente.mes().getValue());
        Assert.assertTrue(corrente.estaNoPresente());
        Assert.assertFalse(corrente.estaNoPassado());
        Assert.assertFalse(corrente.estaNoFuturo());

        final Periodo proximo = corrente.seguinte();
        Assert.assertNotNull(proximo);
        Assert.assertEquals(mes == 12 ? ano + 1 : ano, proximo.ano().getValue());
        Assert.assertEquals(mes == 12 ? 1 : mes + 1, proximo.mes().getValue());
        Assert.assertTrue(proximo.estaNoFuturo());
        Assert.assertFalse(proximo.estaNoPassado());
        Assert.assertFalse(proximo.estaNoPresente());

        Assert.assertTrue(proximo.posterior(corrente));
        Assert.assertFalse(proximo.anterior(corrente));

        final Periodo anterior = corrente.anterior();
        Assert.assertNotNull(anterior);
        Assert.assertEquals(mes == 1 ? ano - 1 : ano, anterior.ano().getValue());
        Assert.assertEquals(mes == 1 ? 12 : mes - 1, anterior.mes().getValue());
        Assert.assertTrue(anterior.estaNoPassado());
        Assert.assertFalse(anterior.estaNoPresente());
        Assert.assertFalse(anterior.estaNoFuturo());

        Assert.assertFalse(anterior.posterior(corrente));
        Assert.assertTrue(anterior.anterior(corrente));

        Assert.assertTrue(corrente.equals(Periodo.corrente()));
        Assert.assertFalse(corrente.equals(proximo));
        Assert.assertFalse(corrente.equals(anterior));
    }

    @Test(expected = PeriodoException.class)
    public void periodos_com_ano_negativo() {
        Periodo.of(-1, 3);
    }

    @Test(expected = PeriodoException.class)
    public void periodos_com_mes_0() {
        Periodo.of(20, 0);
    }

    @Test(expected = PeriodoException.class)
    public void periodos_com_mes_13() {
        Periodo.of(20, 13);
    }
}
